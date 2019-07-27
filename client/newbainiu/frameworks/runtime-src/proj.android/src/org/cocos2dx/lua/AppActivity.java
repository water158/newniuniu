/****************************************************************************
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2011      Zynga Inc.
Copyright (c) 2013-2014 Chukong Technologies Inc.
 
http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
package org.cocos2dx.lua;

import java.io.File;
import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.app.DownloadManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.ActivityInfo;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.location.Location;
import android.location.LocationManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.os.Bundle;
import android.telephony.TelephonyManager;
import android.util.DisplayMetrics;
import android.util.Log;
import android.util.LongSparseArray;
import android.view.WindowManager;
import android.widget.Toast;

import com.dapai178.qfsdk.QFSDK;
import com.dapai178.qfsdk.common.QFStatusCode;
import com.dapai178.qfsdk.transaction.QFPay;
import com.dapai178.qfsdk.transaction.QFPayCallback;
import com.dapai178.qfsdk.transaction.QFPayResult;
import com.dapai178.bainiu.R;


import com.umeng.analytics.MobclickAgent;
import com.umeng.analytics.game.UMGameAgent;
import com.umeng.message.PushAgent;
import com.umeng.message.UmengRegistrar;
import com.umeng.update.UmengUpdateAgent;


@SuppressLint("NewApi") public class AppActivity extends Cocos2dxActivity{


	static String imei1 = "";
	static String imei2 = "";
	static String imsi = "";
	static String macAddress = "";
	static String location = "";
	static String phoneType = "NONE";
	static String resolution = "";
	static AppActivity context;
	static LongSparseArray<Uri> downloadingPaths = new LongSparseArray<Uri>();

	private DownloadCompleteReceiver mCompleteReceiver;
	
    @Override
    //初始化函数
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
		context = this;
		
		UmengUpdateAgent.update(this);

		setKeepScreenOn(true);

		UMGameAgent.init(this);
		PushAgent.getInstance(this).enable();
		PushAgent.getInstance(this).onAppStart();
		PushAgent.getInstance(this).setDebugMode(false);
		 
		// 支付
		// Intent intent = getIntent();// 在游戏的主activity中调用
		// TODO 设置 用户ID和token
		// if (intent == null) {
		// intent = new Intent();
		//
		// }
		// QFSDK.init(this, intent, "10093", "fcd990983449bdd8b77ca1d0e983b388",
		// false);

		// 初始化收银台SDK
		final String appid = getApplicationMetaDataValue(this, "QF_APP_ID");
		final String appkey = getApplicationMetaDataValue(this, "QF_APP_KEY");

		Intent intent = getIntent();// 在游戏的主activity中调用
		if (appid != null && appkey != null) {
			// isPortrait 是否是竖屏显示
			QFSDK.init(this, "190", appid, appkey, false);
		} else {
			System.out.print("no configure appid or appkey!");
		}
		
		
		

     
        if(nativeIsLandScape()) {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE);
        } else {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT);
        }
        
        //2.Set the format of window
        
        TelephonyManager tm = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
		try {
			Class<?> cx = Class.forName("android.telephony.MSimTelephonyManager");
			Object obj = getContext().getSystemService("phone_msim");
			int simId_1 = 0;
			int simId_2 = 1;
			java.lang.reflect.Method md = cx.getMethod("getDeviceId", int.class);
			String imei_1 = ((String) md.invoke(obj, simId_1)).trim();
			String imei_2 = ((String) md.invoke(obj, simId_2)).trim();
			if (imei_1 != null && !imei_1.isEmpty()) {
				imei1 = imei_1;
			}
			if (imei_1 != null && !imei_1.isEmpty()) {
				imei2 = imei_2;
			}
		} catch (Exception e) {
			if (imei1.isEmpty()) {
				imei1 = tm.getDeviceId();
			}
		}
		imsi = tm.getSubscriberId();

		switch (tm.getPhoneType()) {
		case TelephonyManager.PHONE_TYPE_NONE:
			phoneType = "NONE";
			break;
		case TelephonyManager.PHONE_TYPE_GSM:
			phoneType = "GSM";
			break;
		case TelephonyManager.PHONE_TYPE_CDMA:
			phoneType = "CDMA";
			break;
		case TelephonyManager.PHONE_TYPE_SIP:
			phoneType = "SIP";
			break;
		}

		LocationManager lm = (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
		List<String> matchingProviders = lm.getAllProviders();
		for (String prociderString : matchingProviders) {
			Location location = lm.getLastKnownLocation(prociderString);
			if (location != null) {
				AppActivity.location = location.getLongitude() + ", " + location.getLatitude();
				break;
			}
		}

		WindowManager wm = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
		DisplayMetrics displaysMetrics = new DisplayMetrics();
		wm.getDefaultDisplay().getMetrics(displaysMetrics);
		resolution = displaysMetrics.widthPixels + "x" + displaysMetrics.heightPixels;

		macAddress = ((WifiManager) context.getSystemService(Context.WIFI_SERVICE)).getConnectionInfo().getMacAddress();

		mCompleteReceiver = new DownloadCompleteReceiver();
		registerReceiver(mCompleteReceiver, new IntentFilter(DownloadManager.ACTION_DOWNLOAD_COMPLETE));
		
		}
    
    //qifan 
	public String getApplicationMetaDataValue(Context context, String metaKey) {
		Bundle metaData = null;
		String apiKey = null;
		if (context == null || metaKey == null) {
			return null;
		}
		try {
			ApplicationInfo ai = context.getPackageManager().getApplicationInfo(context.getPackageName(), PackageManager.GET_META_DATA);
			if (null != ai) {
				metaData = ai.metaData;
			}
			if (null != metaData) {
				Object value = metaData.get(metaKey);
				if (value != null) {
					apiKey = String.valueOf(value);
				}
			}
		} catch (NameNotFoundException e) {
			System.out.print("无法获取到meta-data，key：" + metaKey);
		}
		return apiKey;
	}

	

	@Override//  activity获得用户焦点，在与用户交互
	protected void onResume() {
		super.onResume();
		UMGameAgent.onResume(this);

	}

	@Override
	protected void onPause() {
		super.onPause();
		UMGameAgent.onPause(this);

	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		// QFSDK.dispose();
		unregisterReceiver(mCompleteReceiver);
	}
	
    private boolean isNetworkConnected() {
            ConnectivityManager cm = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);  
            if (cm != null) {  
                NetworkInfo networkInfo = cm.getActiveNetworkInfo();  
            ArrayList networkTypes = new ArrayList();
            networkTypes.add(ConnectivityManager.TYPE_WIFI);
            try {
                networkTypes.add(ConnectivityManager.class.getDeclaredField("TYPE_ETHERNET").getInt(null));
            } catch (NoSuchFieldException nsfe) {
            }
            catch (IllegalAccessException iae) {
                throw new RuntimeException(iae);
            }
            if (networkInfo != null && networkTypes.contains(networkInfo.getType())) {
                    return true;  
                }  
            }  
            return false;  
        } 
     

	public static String getIpAddress() {
		try {
			for (Enumeration<NetworkInterface> en = NetworkInterface.getNetworkInterfaces(); en.hasMoreElements();) {
				NetworkInterface intf = en.nextElement();
				for (Enumeration<InetAddress> enumIpAddr = intf.getInetAddresses(); enumIpAddr.hasMoreElements();) {
					InetAddress inetAddress = enumIpAddr.nextElement();
					if (!inetAddress.isLoopbackAddress() && inetAddress instanceof Inet4Address) {
						// if (!inetAddress.isLoopbackAddress() && inetAddress
						// instanceof Inet6Address) {
						return inetAddress.getHostAddress().toString();
					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return "0.0.0.0";
	}
	
	public static String getModel() {
		return Build.MODEL;
	}

	public static String getReleaseVersion() {
		return Build.VERSION.RELEASE;
	}

	public static String getUmengDeviceToken() {
		if (context == null) {
			return "";
		}
		
		return UmengRegistrar.getRegistrationId(context);
	}

	public static void reportError(String error) {
		if (context == null) {
			return;
		}
		UMGameAgent.reportError(context, error);
	}

	public static void onEvent(String eventId) {
		if (context == null) {
			return;
		}
		MobclickAgent.onEvent(context, eventId);
	}

	public static String getIMEI1() {
		return imei1 == null ? "" : imei1;
	}

	public static String getIMEI2() {
		return imei2 == null ? "" : imei2;
	}

	public static String getIMSI() {
		return imsi == null ? "" : imsi;
	}

	public static String getMAC() {
		return macAddress == null ? "" : macAddress;
	}

	public static String getLocation() {
		return location == null ? "" : location;
	}

	public static String getPhoneType() {
		return phoneType;
	}

	public static String getResolution() {
		return resolution;
	}
   
	public static void openFeedbackPage() {
		context.startActivity(new Intent(context, UMFeedbackActivity.class));
	}
    

	public static String getUserChannel() {
		if (context != null) {
			try {
				ApplicationInfo appInfo = context.getPackageManager().getApplicationInfo(context.getPackageName(), PackageManager.GET_META_DATA);
				return appInfo.metaData.getString("UMENG_CHANNEL");
			} catch (NameNotFoundException e) {
			}
		}
		return "";
	}
	
	
	/**
	 * 下载apk
	 */
	public static void downloadApk(final String url, final String appName) {
		if (context == null) {
			return;
		}
		context.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				DownloadManager dm = (DownloadManager) context.getSystemService(Context.DOWNLOAD_SERVICE);
				DownloadManager.Request request = new DownloadManager.Request(Uri.parse(url));
				Uri destPath = null;
				File file = context.getExternalFilesDir("zhddz");
				System.out.println(file);
				if (file == null) {
					Toast.makeText(context, context.getString(R.string.msg_no_sdcard), Toast.LENGTH_SHORT).show();
					return;
				}
				if (!file.isDirectory()) {
					Toast.makeText(context, context.getString(R.string.msg_no_sdcard), Toast.LENGTH_SHORT).show();
					return;
				}
				if (!file.exists()) {
					if (!file.mkdirs()) {
						Toast.makeText(context, context.getString(R.string.msg_no_sdcard), Toast.LENGTH_SHORT).show();
						return;
					}
				}
				File destFile = new File(file, appName + ".apk");
				destPath = Uri.fromFile(destFile);
				if (destFile.exists()) {
					Intent i = new Intent(Intent.ACTION_VIEW);
					i.setDataAndType(destPath, "application/vnd.android.package-archive");
					i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
					context.startActivity(i);
					return;
				}
				int size = downloadingPaths.size();
				for (int i = 0; i < size; i++) {
					if (destPath.equals(downloadingPaths.valueAt(i))) {
						Toast.makeText(context, context.getString(R.string.msg_downloading, appName), Toast.LENGTH_SHORT).show();
						return;
					}
				}
				request.setDestinationUri(destPath);
				request.allowScanningByMediaScanner();// 表示允许MediaScanner扫描到这个文件，默认不允许。
				request.setTitle(appName);// 设置下载中通知栏提示的标题
				request.setDescription(appName + context.getString(R.string.lb_downloading));// 设置下载中通知栏提示的介绍
				request.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED);
				long downloadId = dm.enqueue(request);
				downloadingPaths.put(downloadId, destPath);
				Toast.makeText(context, context.getString(R.string.msg_start_download, appName), Toast.LENGTH_SHORT).show();
			}
		});
	}

	/**
	 * 检查应用是否安装。
	 */
	public static boolean isAppInstalled(String pkgName) {
		if (context == null) {
			return false;
		}
		final PackageManager packageManager = context.getPackageManager();
		List<PackageInfo> pinfo = packageManager.getInstalledPackages(0);
		if (pinfo != null) {
			for (int i = 0; i < pinfo.size(); i++) {
				String pn = pinfo.get(i).packageName;
				if (pn.equals(pkgName)) {
					return true;
				}
			}
		}
		return false;
	}
	
	
	/**
	 * 支付
	 * 
	 * @param json
	 */
	public static void payQifan(final String json) {
		if (context == null) {
			Log.e(AppActivity.class.getSimpleName(), "#无法进行支付，context==null");
			return;
		}
		context.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				try {
					JSONObject object = new JSONObject(json);
					QFPay pay = new QFPay();
					/**
					 * 商品ID
					 */
					pay.productId = object.getString("productId");
					/**
					 * 商品名称
					 */
					pay.productName = object.getString("productName");
					/**
					 * 商品价格，以元为单位
					 */
					pay.price = object.getInt("price");
					/**
					 * 是否需要强制对单
					 */
					pay.needValidateOrder = object.getBoolean("needValidateOrder");
					/**
					 * 透传参数，原样返回
					 */
					pay.gameOrder = object.getString("gameOrder");

					/**
					 * 是否短信快冲
					 */
					pay.isQuickPay = object.getBoolean("isQuickPay");
					QFSDK.pay(pay, new QFPayCallback() {
						@Override
						public void onCallback(final QFPayResult result, QFPay pay) {
							if (result.isSuccess()) {
								Toast.makeText(context, context.getString(R.string.pay_success), Toast.LENGTH_SHORT).show();
								context.runOnGLThread(new Runnable() {
									@Override
									public void run() {
										int id = Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("onQifanPayFinish", "true");
										Cocos2dxLuaJavaBridge.releaseLuaFunction(id);
									}
								});
							} else if (result.statusCode == QFStatusCode.CANCEL) {
								context.runOnGLThread(new Runnable() {
									@Override
									public void run() {
										int id = Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("onQifanPayFinish", "false");
										Cocos2dxLuaJavaBridge.releaseLuaFunction(id);
									}
								});
							} else if (result.statusCode == QFStatusCode.FAILED) {
								Toast.makeText(context, context.getString(R.string.pay_failed), Toast.LENGTH_SHORT).show();
								context.runOnGLThread(new Runnable() {
									@Override
									public void run() {
										int id = Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("onQifanPayFinish", "false");
										Cocos2dxLuaJavaBridge.releaseLuaFunction(id);
									}
								});
							} else {
								Toast.makeText(context, context.getString(R.string.pay_failed_width_code, result.statusCode), Toast.LENGTH_SHORT).show();
								context.runOnGLThread(new Runnable() {
									@Override
									public void run() {
										int id = Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("onQifanPayFinish", "false");
										Cocos2dxLuaJavaBridge.releaseLuaFunction(id);
									}
								});
							}
						}
					});
				} catch (JSONException e) {
					Log.e(AppActivity.class.getSimpleName(), "#支付失败", e);
					context.runOnGLThread(new Runnable() {
						@Override
						public void run() {
							int id = Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("onQifanPayFinish", "false");
							Cocos2dxLuaJavaBridge.releaseLuaFunction(id);
						}
					});
				}
			}
		});
	}
	

    
    private static native boolean nativeIsLandScape();
    private static native boolean nativeIsDebug();
    
	private static class DownloadCompleteReceiver extends BroadcastReceiver {

		@Override
		public void onReceive(Context context, Intent intent) {
			long completeDownloadId = intent.getLongExtra(DownloadManager.EXTRA_DOWNLOAD_ID, -1);
			if (downloadingPaths.indexOfKey(completeDownloadId) >= 0) {
				Uri uri = downloadingPaths.get(completeDownloadId);
				if (uri == null) {
					return;
				}
				Intent i = new Intent(Intent.ACTION_VIEW);
				i.setDataAndType(uri, "application/vnd.android.package-archive");
				i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
				context.startActivity(i);
			}
		}
	};
	
	
    
}
