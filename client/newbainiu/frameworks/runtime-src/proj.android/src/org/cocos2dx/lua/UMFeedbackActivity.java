package org.cocos2dx.lua;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.UUID;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.provider.MediaStore;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v4.widget.SwipeRefreshLayout.OnRefreshListener;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.dapai178.bainiu.R;
import com.umeng.fb.FeedbackAgent;
import com.umeng.fb.SyncListener;
import com.umeng.fb.model.Conversation;
import com.umeng.fb.model.Reply;

public class UMFeedbackActivity extends Activity {

	private ListView mListView;
	private Conversation mConversation;
	private Context mContext;
	private ReplyAdapter adapter;
	private Button sendBtn;
	private EditText inputEdit;
	private SwipeRefreshLayout mSwipeRefreshLayout;
	private final int VIEW_TYPE_COUNT = 2;
	private final int VIEW_TYPE_USER = 0;
	private final int VIEW_TYPE_DEV = 1;

	private Handler mHandler = new Handler() {
		@Override
		public void handleMessage(Message msg) {
			adapter.notifyDataSetChanged();
			mListView.setSelection(adapter.getCount() - 1);
		}
	};

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.umeng_fb_activity_custom);
		mContext = this;
		mConversation = new FeedbackAgent(this).getDefaultConversation();
		initView();
		adapter = new ReplyAdapter();
		mListView.setAdapter(adapter);
		sync();
	}

	private void initView() {
		mListView = (ListView) findViewById(R.id.fb_reply_list);
		sendBtn = (Button) findViewById(R.id.fb_send_btn);
		inputEdit = (EditText) findViewById(R.id.fb_send_content);
		// ����ˢ�����
		mSwipeRefreshLayout = (SwipeRefreshLayout) findViewById(R.id.fb_reply_refresh);
		sendBtn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				String content = inputEdit.getText().toString();
				inputEdit.getEditableText().clear();
				if (!TextUtils.isEmpty(content)) {
					// ��������ӵ��Ự�б�
					mConversation.addUserReply(content);
					// ˢ����ListView
					mHandler.sendMessage(new Message());
					// ����ͬ��
					sync();
				}
			}
		});

		// ����ˢ��
		mSwipeRefreshLayout.setOnRefreshListener(new OnRefreshListener() {
			@Override
			public void onRefresh() {
				sync();
			}
		});

		// �ֶ�ˢ��
		findViewById(R.id.refresh_imageView).setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				mSwipeRefreshLayout.setRefreshing(true);
				sync();
			}
		});

		// ����
		findViewById(R.id.back_imageView).setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				finish();
			}
		});
		findViewById(R.id.exit_textView).setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				finish();
			}
		});

		findViewById(R.id.sendPhoto_imageView).setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				Intent intent = new Intent("android.intent.action.PICK", MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
				((Activity) mContext).startActivityForResult(intent, 1);
			}
		});
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		if (resultCode == -1 && requestCode == 1 && data != null) {
			// Log.e(TAG, "data.getDataString -- " + data.getDataString());
			if (UMengB.a(mContext, data.getData())) {
				UMengB.a(mContext, data.getData(), "R" + UUID.randomUUID().toString(), new Handler() {
					@Override
					public void handleMessage(Message msg) {
						super.handleMessage(msg);
						mConversation.addUserReply("", (String) msg.obj, "image_reply", -1.0F);
						sync();
					}
				});
			}
		}
	}

	// ����ͬ��
	private void sync() {
		mConversation.sync(new SyncListener() {

			@Override
			public void onSendUserReply(List<Reply> replyList) {
			}

			@Override
			public void onReceiveDevReply(List<Reply> replyList) {
				// SwipeRefreshLayoutֹͣˢ��
				mSwipeRefreshLayout.setRefreshing(false);
				// ������Ϣ��ˢ��ListView
				mHandler.sendMessage(new Message());
				// ���������û���µĻظ����ݣ��򷵻�
				if (replyList == null || replyList.size() < 1) {
					return;
				}
			}
		});
		// ����adapter��ˢ��ListView
		adapter.notifyDataSetChanged();
		mListView.setSelection(adapter.getCount() - 1);
	}

	// adapter
	class ReplyAdapter extends BaseAdapter {

		@Override
		public int getCount() {
			return mConversation.getReplyList().size();
		}

		@Override
		public Object getItem(int arg0) {
			return mConversation.getReplyList().get(arg0);
		}

		@Override
		public long getItemId(int arg0) {
			return arg0;
		}

		@Override
		public int getViewTypeCount() {
			// ���ֲ�ͬ��Tiem����
			return VIEW_TYPE_COUNT;
		}

		@Override
		public int getItemViewType(int position) {
			// ��ȡ�����ظ�
			Reply reply = mConversation.getReplyList().get(position);
			if (Reply.TYPE_DEV_REPLY.equals(reply.type)) {
				// �����߻ظ�Item����
				return VIEW_TYPE_DEV;
			} else {
				// �û��������ظ�Item����
				return VIEW_TYPE_USER;
			}
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			ViewHolder holder = null;
			// ��ȡ�����ظ�
			Reply reply = mConversation.getReplyList().get(position);
			if (convertView == null) {
				// ����Type�����������ز�ͬ��Item����
				if (Reply.TYPE_DEV_REPLY.equals(reply.type)) {
					// �����ߵĻظ�
					convertView = LayoutInflater.from(mContext).inflate(R.layout.umeng_fb_dev_reply, null);
				} else {
					// �û��ķ������ظ�
					convertView = LayoutInflater.from(mContext).inflate(R.layout.umeng_fb_user_reply, null);
				}

				// ����ViewHolder����ȡ����View
				holder = new ViewHolder();
				holder.replyContent = (TextView) convertView.findViewById(R.id.fb_reply_content);
				holder.replyContentImg = (ImageView) convertView.findViewById(R.id.fb_reply_content_img);
				holder.replyProgressBar = (ProgressBar) convertView.findViewById(R.id.fb_reply_progressBar);
				holder.replyStateFailed = (ImageView) convertView.findViewById(R.id.fb_reply_state_failed);
				holder.replyData = (TextView) convertView.findViewById(R.id.fb_reply_date);
				convertView.setTag(holder);
			} else {
				holder = (ViewHolder) convertView.getTag();
			}

			// �������������
			// ����Reply������
			if (reply.content_type.equals(Reply.CONTENT_TYPE_TEXT_REPLY)) {
				holder.replyContent.setVisibility(View.VISIBLE);
				if (holder.replyContentImg != null) {
					holder.replyContentImg.setVisibility(View.GONE);
				}
				holder.replyContent.setText(reply.content);
			} else if(reply.content_type.equals(Reply.CONTENT_TYPE_IMAGE_REPLY)) {
				holder.replyContent.setVisibility(View.GONE);
				holder.replyContentImg.setVisibility(View.VISIBLE);
				com.umeng.fb.image.a.a().a(com.umeng.fb.util.c.b(mContext, reply.reply_id), holder.replyContentImg, getPhotoSize(mContext));
			}
			
			// ��AppӦ�ý��棬���ڿ����ߵ�Reply����statusû������
			if (!Reply.TYPE_DEV_REPLY.equals(reply.type)) {
				// ����Reply��״̬������replyStateFailed��״̬
				if (Reply.STATUS_NOT_SENT.equals(reply.status)) {
					holder.replyStateFailed.setVisibility(View.VISIBLE);
				} else {
					holder.replyStateFailed.setVisibility(View.GONE);
				}

				// ����Reply��״̬������replyProgressBar��״̬
				if (Reply.STATUS_SENDING.equals(reply.status)) {
					holder.replyProgressBar.setVisibility(View.VISIBLE);
				} else {
					holder.replyProgressBar.setVisibility(View.GONE);
				}
			}

			// �ظ���ʱ�����ݣ��������QQ����Reply֮�����100000ms��չʾʱ��
			if ((position + 1) < mConversation.getReplyList().size()) {
				Reply nextReply = mConversation.getReplyList().get(position + 1);
				if (nextReply.created_at - reply.created_at > 100000) {
					Date replyTime = new Date(reply.created_at);
					SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
					holder.replyData.setText(sdf.format(replyTime));
					holder.replyData.setVisibility(View.VISIBLE);
				} else {
					holder.replyData.setVisibility(View.GONE);
				}
			}
			return convertView;
		}
		
		private int getPhotoSize(Context context) {
	        DisplayMetrics metrics = new DisplayMetrics();
	        WindowManager windowManager = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
	        windowManager.getDefaultDisplay().getMetrics(metrics);
	        return metrics.widthPixels > metrics.heightPixels ? metrics.heightPixels : metrics.widthPixels;
	    }

		class ViewHolder {
			TextView replyContent;
			ImageView replyContentImg;
			ProgressBar replyProgressBar;
			ImageView replyStateFailed;
			TextView replyData;
		}
	}

}
