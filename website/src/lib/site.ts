export const SITE_URL = 'https://jugaadi.vercel.app';
export const SITE_NAME = 'Jugaadi';

// APK, pre-launch/pre-Play-Store (Google Drive). Direct-download link triggers the download
// immediately; the Drive view link is the fallback shown if that doesn't start automatically.
const DRIVE_FILE_ID = '1YrbTHhA8oYYRI28VCqIT7nN5FcvC952b';
export const APK_DOWNLOAD_URL = `https://drive.usercontent.google.com/download?id=${DRIVE_FILE_ID}&export=download&confirm=t`;
export const APK_DRIVE_VIEW_URL = `https://drive.google.com/file/d/${DRIVE_FILE_ID}/view?usp=sharing`;
