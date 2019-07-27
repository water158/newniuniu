package org.cocos2dx.lua;

import com.umeng.fb.image.b;
import com.umeng.fb.util.c;

import android.content.ContentResolver;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.BitmapFactory;
import android.graphics.BitmapFactory.Options;
import android.graphics.Rect;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Handler;
import android.os.Message;
import android.util.DisplayMetrics;
import android.view.WindowManager;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

class UMengB extends b {
	public UMengB() {
	}

	private static void b(Bitmap var0) {
		if (var0 != null && !var0.isRecycled()) {
			var0.recycle();
			var0 = null;
		}

	}

	public static void a(final Context var0, final Uri var1, final String var2, final Handler handler) {
		(new AsyncTask<Void, Boolean, Boolean>() {
			@Override
			protected Boolean doInBackground(Void... var1x) {
				return Boolean.valueOf(UMengB.c(var0, var1, var2));
			}

			@Override
			protected void onPostExecute(Boolean var1x) {
				super.onPostExecute(var1x);

				if (var1x.booleanValue()) {
					Message var2x = new Message();
					var2x.obj = var2;
					handler.sendMessage(var2x);
				}
			}
		}).execute(new Void[0]);
	}

	private static boolean c(Context var0, Uri var1, String var2) {
		boolean var3 = true;
		String var4 = c.b(var0, var2);
		File var5 = new File(var4);
		FileOutputStream var6 = null;
		Bitmap var7 = null;

		try {
			var7 = a(b(var0, var1));
			var6 = new FileOutputStream(var5);
			if (var7 != null && var7.compress(CompressFormat.JPEG, 80, var6)) {
				;
			}
		} catch (Exception var17) {
			var5.delete();
			var17.printStackTrace();
			var3 = false;
		} finally {
			b(var7);

			try {
				var6.close();
			} catch (IOException var16) {
				var16.printStackTrace();
			}

		}

		return var3;
	}

	private static synchronized Bitmap b(Context var0, Uri var1) throws IOException {
		ContentResolver var2 = var0.getContentResolver();
		InputStream var3 = var2.openInputStream(var1);
		Options var4 = new Options();
		var4.inJustDecodeBounds = true;
		BitmapFactory.decodeStream(var3, (Rect) null, var4);
		var3.close();
		if (var4.outWidth != -1 && var4.outHeight != -1) {
			int var5 = var4.outHeight > var4.outWidth ? var4.outHeight : var4.outWidth;
			int var6 = a(var0);
			int var7 = var5 > var6 ? var5 / var6 : 1;
			var4.inJustDecodeBounds = false;
			var4.inSampleSize = var7;
			var3 = var2.openInputStream(var1);
			Bitmap var8 = BitmapFactory.decodeStream(var3, (Rect) null, var4);
			var3.close();
			return var8;
		} else {
			return null;
		}
	}

	private static int a(Context var0) {
		DisplayMetrics var1 = new DisplayMetrics();
		WindowManager var2 = (WindowManager) ((WindowManager) var0.getSystemService(Context.WINDOW_SERVICE));
		var2.getDefaultDisplay().getMetrics(var1);
		return var1.heightPixels > var1.widthPixels ? var1.heightPixels : var1.widthPixels;
	}

}
