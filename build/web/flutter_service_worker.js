'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {
  // (여기에 모든 리소스 목록을 유지)
};

// 설치 이벤트에서 캐시할 리소스 추가
self.addEventListener('install', (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, { 'cache': 'reload' })));
    })
  );
});

// 활성화 이벤트에서 이전 캐시 삭제 및 새 캐시 추가
self.addEventListener('activate', (event) => {
  event.waitUntil(async function () {
    try {
      const contentCache = await caches.open(CACHE_NAME);
      const tempCache = await caches.open(TEMP);
      const manifestCache = await caches.open(MANIFEST);
      const manifest = await manifestCache.match('manifest');

      // 이전 캐시가 없으면 전체 캐시를 삭제
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        const newCache = await caches.open(CACHE_NAME);
        for (const request of await tempCache.keys()) {
          const response = await tempCache.match(request);
          await newCache.put(request, response);
        }
        await caches.delete(TEMP);
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        self.clients.claim();
        return;
      }

      const oldManifest = await manifest.json();
      const origin = self.location.origin;

      // 이전 캐시에서 새로운 리소스가 아닌 것을 삭제
      for (const request of await contentCache.keys()) {
        const key = request.url.substring(origin.length + 1);
        if (key === '') {
          key = '/';
        }
        if (!RESOURCES[key] || RESOURCES[key] !== oldManifest[key]) {
          await contentCache.delete(request);
        }
      }

      // 새 캐시의 TEMP 파일 추가
      for (const request of await tempCache.keys()) {
        const response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      self.clients.claim();
      return;
    } catch (err) {
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// Fetch 이벤트 처리
self.addEventListener('fetch', (event) => {
  // (기존 fetch 이벤트 처리 코드 유지)
});

// 메시지 이벤트 처리
self.addEventListener('message', (event) => {
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
