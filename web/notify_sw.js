// Service worker kecil khusus notifikasi. Chrome di Android (termasuk PWA)
// hanya mau menampilkan notifikasi lewat service worker.
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (event) => event.waitUntil(self.clients.claim()));

// Saat notifikasi diketuk: tutup notifikasinya lalu buka kembali aplikasinya.
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const appUrl = new URL('./', self.location.href).href;
  event.waitUntil(
    self.clients
      .matchAll({ type: 'window', includeUncontrolled: true })
      .then((list) => {
        for (const client of list) {
          if (client.url.startsWith(appUrl) && 'focus' in client) {
            return client.focus();
          }
        }
        return self.clients.openWindow(appUrl);
      })
  );
});
