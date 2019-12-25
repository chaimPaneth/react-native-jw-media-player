package com.appgoalz.rnjwplayer;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.ref.WeakReference;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;

/**
 * Downloads images and returns them as bitmap.
 * <p>
 * Clients need to extend it and implement their own onPostExecute method.
 */
public class DownloadImageTask extends AsyncTask<String, Void, Bitmap> {

	interface ImageDownloadListener {
		void onBitmapReady(Bitmap bitmap);
	}

	WeakReference<ImageDownloadListener> mImageDownloadListener;

	public DownloadImageTask(ImageDownloadListener listener) {
		this.mImageDownloadListener = new WeakReference<>(listener);
	}

	@Override
	protected Bitmap doInBackground(String... urls) {
		if (urls.length != 1 || urls[0] == null) {
			return null;
		}

		Bitmap bitmap = null;
		URL url;
		try {
			url = new URL(urls[0]);
		} catch (MalformedURLException e) {
			e.printStackTrace();
			return null;
		}
		HttpURLConnection urlConnection = null;
		InputStream stream = null;
		try {
			urlConnection = (HttpURLConnection)url.openConnection();
			if (urlConnection.getResponseCode() == HttpURLConnection.HTTP_OK) {

				stream = new BufferedInputStream(urlConnection.getInputStream());
				bitmap = BitmapFactory.decodeStream(stream);
			}
		} catch (IOException e) {
			/* ignore */
			e.printStackTrace();
		} finally {
			if (urlConnection != null) {
				urlConnection.disconnect();
			}
			if (stream != null) {
				try {
					stream.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
		return bitmap;
	}

	@Override
	protected void onPostExecute(Bitmap bitmap) {
		if (mImageDownloadListener.get() != null) {
			mImageDownloadListener.get().onBitmapReady(bitmap);
		}
	}
}
