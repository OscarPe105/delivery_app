/* eslint-disable no-undef */
importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyB-dcsAHoET-rg21-C-T0qQIaoxLYqgFTA',
  appId: '1:397640943349:web:46f26f58525316e2a5a7bc',
  messagingSenderId: '397640943349',
  projectId: 'delivery-app-15f53',
  storageBucket: 'delivery-app-15f53.appspot.com',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const { title, body } = payload.notification ?? {};
  const notificationTitle = title ?? 'Nuevo mensaje';
  const notificationOptions = {
    body: body ?? 'Tienes una nueva notificación',
    icon: '/icons/Icon-192.png',
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});

