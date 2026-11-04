importScripts(
  'https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js',
);
importScripts(
  'https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js',
);

firebase.initializeApp({
  apiKey: 'AIzaSyAhA4BGpo2h2CahMr-uXaqZk2NW2SZONfc',
  appId: '1:1030557146387:web:c0c95525fba839adbbcee6',
  messagingSenderId: '1030557146387',
  projectId: 'flutter-chat-45947',
  authDomain: 'flutter-chat-45947.firebaseapp.com',
  storageBucket: 'flutter-chat-45947.firebasestorage.app',
});

firebase.messaging();
