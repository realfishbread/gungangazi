'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
let CORE = ["main.dart.js", "index.html", "flutter_bootstrap.js"];


const RESOURCES = {
"assets/AssetManifest.bin": "4bb2753f1a1034b577d6a000e15c37b6",
"assets/AssetManifest.bin.json": "5a43677b26104488c92b7ef46df3d617",
"assets/AssetManifest.json": "4be4ac985623e8df76d70d08af11cd30",
"assets/assets/person/jindan%2520Stomachache.jpg": "a641dfd70ebeba0ff430767ac37b9582",
"assets/assets/person/jindan.jpg": "e9a81b8ac6acbf625ddf4c910bd9de1f",
"assets/assets/person/jindan.png": "b9341524122b94e39c0c42760cfb7e71",
"assets/assets/person/jindan2.png": "ea5ea0ff93200ec26d1b296de97cf7e2",
"assets/assets/person/jindan2.webp": "51555745fb9f03598aea1159dd3afc88",
"assets/assets/person/jindan_armsick1.jpg": "46eae967f519e73c4eaca816f51c9e67",
"assets/assets/person/jindan_armsick10.jpg": "79db06008084987d9eb33e53899d1ee2",
"assets/assets/person/jindan_armsick11.jpg": "ad52d3bced7106b491649f542ca1b181",
"assets/assets/person/jindan_armsick12.jpg": "11ab222e48f40d872a56a0cd0039541f",
"assets/assets/person/jindan_armsick13.jpg": "092c4332e3a57168c60eaa3fe5760224",
"assets/assets/person/jindan_armsick16.jpg": "18cbfd9d0131ce0ce59affe7245ea707",
"assets/assets/person/jindan_armsick3.jpg": "bd64a6f4c244dde3df69f5c944375e77",
"assets/assets/person/jindan_armsick4.jpg": "88cd273662beb0c395ec62b4e60e9a8a",
"assets/assets/person/jindan_armsick5.jpg": "940303a75cfc2025dcd2404496458be1",
"assets/assets/person/jindan_armsick6.jpg": "1968f8ea3d10440194fe7f6e67b6b897",
"assets/assets/person/jindan_armsick7.jpg": "08e20b9721f5a865f3906c5b80f6690f",
"assets/assets/person/jindan_armsick8.jpg": "8ebd86d785dacfab30d72868be129108",
"assets/assets/person/jindan_armsick9.jpg": "4ef68be8fd5325048c1037ad09b38d93",
"assets/assets/person/jindan_cold.jpg": "ae8a382c033fdd87d48e1edbf50d5a3c",
"assets/assets/person/jindan_move.mp4": "e16701eab3697a82a492cccea3f829fe",
"assets/assets/person/jindan_mve.mp4": "7e35bb54e7d895993e258dd3cec68e19",
"assets/assets/person/jindan_N1.jpg": "5281e4d604e9290b79aea6c0259e3a35",
"assets/assets/person/jindan_N10.jpg": "bb300925262ce9f3f36443d3a39b8de5",
"assets/assets/person/jindan_N11.jpg": "76631d615722f92c3d8ca0381c598d5d",
"assets/assets/person/jindan_N12.jpg": "33208a05957219b3acc8057596fbdfff",
"assets/assets/person/jindan_N2.jpg": "4112cb9d7965156332d28779db2d6de7",
"assets/assets/person/jindan_N3.jpg": "a34f1ce8be2acc1107ce27aa9c283ea3",
"assets/assets/person/jindan_N4.jpg": "9ee88c1d20f29ec7090ea90e3f344dcd",
"assets/assets/person/jindan_N5.jpg": "898b2f26edd06e5a956de43bd9a0bd34",
"assets/assets/person/jindan_N6.jpg": "2169bfc2418a9aad60af52a67ae674aa",
"assets/assets/person/jindan_N7.jpg": "45982604113aee3ca0ffe3c43c757463",
"assets/assets/person/jindan_N8.jpg": "df1847fa020a301663a6ab9a5230766b",
"assets/assets/person/jindan_N9.jpg": "cf0e255074199b394a22807be945e9d8",
"assets/assets/person/jindan_normal.jpg": "4edf397642af4270160fef022a0df44e",
"assets/assets/person/jindan_sad.jpg": "811261aef001f4a1886ae7cec7fd198a",
"assets/assets/person/jindan_sad.mp4": "a8ce8998cd61a6d80fa058d3eeb13d72",
"assets/assets/person/jindan_sad1.jpg": "8b0a4d4ba4562ab49f5c39a312e1be31",
"assets/assets/person/jindan_sad2.jpg": "00a3006ab02e2df0a3c64db53b323fe5",
"assets/assets/person/jindan_sad3.jpg": "dd90eef800b48b0ab7e82c9a21972ca0",
"assets/assets/person/jindan_sad4.jpg": "412ab492cae4087178bc95cadf543eca",
"assets/assets/person/jindan_sad5.jpg": "c64ed19d3f0be4b69630639789e249d5",
"assets/assets/person/jindan_sad6.jpg": "429a1b15c2fc2012ad3afe3b7d6d8570",
"assets/assets/person/jindan_sad7.jpg": "73fefa91007978be1ad933b85abfae61",
"assets/assets/person/jindan_sad8.jpg": "e765864c64174563b105aa46b1ed8998",
"assets/assets/person/jindan_sad9.jpg": "17e9641c4c7f21b8011c7321b9a2574e",
"assets/assets/person/jindan_Stomach.mp4": "6edc0b6fc3f58a1fd202f7dfbc1d2a40",
"assets/assets/person/jindan_stomach1.jpg": "7e2ca950538b0e14125f2862ebab4744",
"assets/assets/person/jindan_stomach2.jpg": "4f7911fb7bd067192fd079d99a8d167e",
"assets/assets/person/jindan_stomach3.jpg": "44edefabf0253c1ab0fcef2a8a1e7142",
"assets/assets/person/jindan_stomach4.jpg": "fb12565e9e19b0970b192099f375d8f6",
"assets/assets/person/jindan_stomach5.jpg": "7bd29e60ffb9b5b75602b38c881b2457",
"assets/assets/person/jindan_stomach6.jpg": "64e5a5901a5dbc99f37c6de853c91e0c",
"assets/assets/person/jindan_stomach7.jpg": "41754eb16c76be426e89d77248cb0f95",
"assets/assets/person/KakaoTalk_20240928_125154273.jpg": "12852c07dbaa01cee9cefa4c4923b7fb",
"assets/assets/person/KakaoTalk_20240928_125154273_01.jpg": "6389ea37eb971677dbf2f26a9c818cdd",
"assets/assets/person/KakaoTalk_20240928_125154273_02.jpg": "12852c07dbaa01cee9cefa4c4923b7fb",
"assets/assets/person/KakaoTalk_20240928_125154273_03.jpg": "6389ea37eb971677dbf2f26a9c818cdd",
"assets/assets/person/KakaoTalk_20240928_125154273_04.jpg": "096cdc9d29fc59efdc94c0877a923939",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "662585cfb5ee4173b8d26c2f68dc8bce",
"assets/NOTICES": "caf3be0e6d78cb160b371d61948db756",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/shaders/ink_sparkle.frag": "9bb2aaa0f9a9213b623947fa682efa76",
"canvaskit/canvaskit.js": "e3d44d78c7b2a37405529ebc65d40ff5",
"canvaskit/canvaskit.js.symbols": "7591a27e90a9f47b73104b5beea5f732",
"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/chromium/canvaskit.js": "ed3bb46c8a412dae23314fa3b08eb526",
"canvaskit/chromium/canvaskit.js.symbols": "5e3724af47d205af948bfc9946c80dc4",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/skwasm.js": "686f426cd20984ab51f015028c3dc900",
"canvaskit/skwasm.js.symbols": "601a3adb24ac6b21b8e89735a27416f3",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"canvaskit/skwasm.worker.js": "e35e7fbec8f04f340add4f6ace89a29c",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "e80945fe3613e9045a2d59c3213b21f9",
"flutter_bootstrap.js": "f93611ce364c273c2577b5ee2a6041b9",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "76e094adeecd7fb308ff52feee7a1f7b",
"/": "76e094adeecd7fb308ff52feee7a1f7b",
"main.dart.js": "b74bfe238778a43fcd3f36cffb1357dd",
"manifest.json": "ffbca102d170ebf6817d1f414a18e2d3",
"version.json": "b78ba47bafc44bd62d180a59c13551c9"
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
