'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "3c80049afe6edd559288485a9212af42",
"assets/AssetManifest.bin.json": "cb96e7694dc49eb3d668ebab5569771e",
"assets/AssetManifest.json": "66ae566c19703fa0a3e377649ca14843",
"assets/assets/dog.jpg": "5afbdbd68fad24d3fe1002ce604aacfc",
"assets/assets/fonts/NanumSquareB.ttf": "e850eb664f41c0828a8aac6f1d09b643",
"assets/assets/icons/google_icon.png": "5ac025325e694989d54b499057cd4e66",
"assets/assets/icons/kakao_icon.png": "b9018d85d6d71d477de7248ca527adb5",
"assets/assets/logo.png": "e847b5d976a4606b14f7095de06f710f",
"assets/assets/person/0am/0am.jpg": "ff6b73b3e674f501f989596221977eda",
"assets/assets/person/0am/0am1.jpg": "9b6325d9e057f16516d1a37b2f24b108",
"assets/assets/person/0am/0am2.jpg": "4c0d51d76b4079be0d6392f2a4785c86",
"assets/assets/person/0am/0amarm1.jpg": "1e4bce09e134b518b91c4a1d093b3b0f",
"assets/assets/person/0am/0amarm2.jpg": "4dac8d816ac2f60df43c2647e479581f",
"assets/assets/person/0am/0amarm3.jpg": "3e646848f55c7b5da9024f2492229755",
"assets/assets/person/0am/0ambrush1.jpg": "d8c6f7a1464e9a5ee54d10e5d2ab3b50",
"assets/assets/person/0am/0ambrush2.jpg": "d8c6f7a1464e9a5ee54d10e5d2ab3b50",
"assets/assets/person/0am/0amddong1.jpg": "9bbead9ec7dccca5fa386bb4f95bf5ef",
"assets/assets/person/0am/0amddong2.jpg": "771181e762f425e8dfc07d835431189d",
"assets/assets/person/0am/0amddong3.jpg": "8bf25a067a8482aa9dde48ed29b48c9d",
"assets/assets/person/0am/0amdizzy1.jpg": "f3cf9c3195857f650f8bf6d42c4e51d1",
"assets/assets/person/0am/0amdizzy2.jpg": "ed170c664c406abd2fece226b32a1ca2",
"assets/assets/person/0am/0amdizzy3.jpg": "96f6d23e6e90cd19abeb5c075b9cf6a0",
"assets/assets/person/0am/0amdrinkwater.jpg": "1aaf038e7741fc8c92d51650a2872e2f",
"assets/assets/person/0am/0amdrinkwater1.jpg": "89a24c56186fa1e4c0f9d5650db9e099",
"assets/assets/person/0am/0amdrinkwater2.jpg": "80e795d04012390c802545729a3d8520",
"assets/assets/person/0am/0amheadache1.jpg": "4eebc36ffcd7e7f44caed695a0bc630e",
"assets/assets/person/0am/0amheadache2.jpg": "86582ff5b684aa3e7799ab8180ec34ca",
"assets/assets/person/0am/0amheadache3.jpg": "b3c9e8565356afe35ac182b37fb8b500",
"assets/assets/person/0am/0ammeal1.jpg": "26b9eab9ca49b286486f817ab188aa16",
"assets/assets/person/0am/0ammeal2.jpg": "e26d628685a55ab16ffea7f9ed063d78",
"assets/assets/person/0am/0ammeal3.jpg": "b696805daef7c5f2045528361009d087",
"assets/assets/person/0am/0amnobrush1.jpg": "ecb4d16e8210127b9d8cef5f77e71407",
"assets/assets/person/0am/0amnobrush2.jpg": "d882825c3e4222e0d8a726aea3d47813",
"assets/assets/person/0am/0amnobrush3.jpg": "3d0184c9a8c01c4de5ddbe806cdd3446",
"assets/assets/person/0am/0amstomach1.jpg": "eb5e9bfd5289577e8113d702b883b208",
"assets/assets/person/0am/0amstomach2.jpg": "9e5de79d1c45b25dad14e0d3778064c4",
"assets/assets/person/0am/0amstomach3.jpg": "cf56c993d187c1506065f5db49ab1507",
"assets/assets/person/0am/0amsu1.jpg": "c02de12236619e518fe8f0a80998bd8a",
"assets/assets/person/0am/0amsu2.jpg": "aa57a5b6fea9bfdf90f0a45c811debcd",
"assets/assets/person/0am/0amsu3.jpg": "8b9244474edb6ab7c0886c8e9aa2d8a8",
"assets/assets/person/0am/0amtired.jpg": "973d4894efa2e66b6b84bfdbc2d56a21",
"assets/assets/person/0am/0amtired2.jpg": "16633df1371c13520b2d89f889793472",
"assets/assets/person/0am/0amtired3.jpg": "a04b825e06bf4a9a413a64f2e13bd8bc",
"assets/assets/person/0am/0amtouch1.jpg": "651a0ac6fc183aecc278257cb11bf814",
"assets/assets/person/0am/0amtouch2.jpg": "6b4b9405714d5d032f4fadab750b6188",
"assets/assets/person/0am/0amtouch3.jpg": "81e9e474e77c8d14871d70214b871143",
"assets/assets/person/0am/sleeping1.jpg": "9eb57719b8abdfd4cbd1964c5f34f604",
"assets/assets/person/0am/sleeping2.jpg": "c5ca1b015d5c6c0ce7067ec5464f90e6",
"assets/assets/person/0am/sleeping3.jpg": "f172816967f18836724bf46a6a78dc09",
"assets/assets/person/0am/slhead1.jpg": "9377257f9ea3d975f778d97e1c091d56",
"assets/assets/person/0am/slhead2.jpg": "d48cf8b3afcc403951612229366af47e",
"assets/assets/person/0am/slhead3.jpg": "b5a148c0f5e12a4fd08e041d68b68d6f",
"assets/assets/person/default/1.jpg": "049e32fe4e58cad3c1a7e2f59ddc5144",
"assets/assets/person/default/2.jpg": "b57edfd429e96a70c48654bc364713f6",
"assets/assets/person/default/3.jpg": "c0efaced43d37e382f0dd9fd3e29f098",
"assets/assets/person/default/angry1.jpg": "64c932300cd84c9135b2c7881025e1cd",
"assets/assets/person/default/angry2.jpg": "126746a0fb8147f9f80cc54a3a481de7",
"assets/assets/person/default/angry3.jpg": "28118b62dc547ec14f69b8262ec24936",
"assets/assets/person/default/angry4.jpg": "aad71e1304e28a8252bd1de82a53ef8b",
"assets/assets/person/default/angry5.jpg": "cb7714c1c267e6eec455121664d759d3",
"assets/assets/person/default/angry6.jpg": "76fecc9e4e54a9f050986329ac792fc0",
"assets/assets/person/default/arm1.jpg": "242d02f018eb9efc51b5dc3d484b33b4",
"assets/assets/person/default/arm2.jpg": "92996c590b67f1e5ada230dff16f238a",
"assets/assets/person/default/arm3.jpg": "9e7088b06e097ff9e323f4e4fef47717",
"assets/assets/person/default/brush.jpg": "a020d2dcd745e14b891b5ea5c5b310df",
"assets/assets/person/default/brush1.jpg": "56d6a738a072aebc5beda83ca9ec9e97",
"assets/assets/person/default/ddongtalk.jpg": "32c4645486ae06a4cd45a3e18835bdae",
"assets/assets/person/default/ddongtalk2.jpg": "ab0ec7ab5e4dad7d8f23581628467d59",
"assets/assets/person/default/ddongtalk3.jpg": "955894a8238f6b27fc3432cd3bd22b79",
"assets/assets/person/default/dizzy1.jpg": "b0ea2ed7357e5362aec447a5278daf68",
"assets/assets/person/default/dizzy2.jpg": "f9ab62f7b2a0cca285c388d93807d6d4",
"assets/assets/person/default/dizzy3.jpg": "f27f42cb818667fc396af9a72605330a",
"assets/assets/person/default/drinkwater1.jpg": "5b9ae294ad98dd23260f1440092f49b5",
"assets/assets/person/default/drinkwater2.jpg": "9ca5a3dda9139b806c9190aab77207f8",
"assets/assets/person/default/drinkwater3.jpg": "d285e3f41747c07231a44b827fa958dd",
"assets/assets/person/default/eatingmeal1.jpg": "b13bdb5352f2d622529c57f5d30172be",
"assets/assets/person/default/eatingmeal2.jpg": "40c342ef78e07a1873bfc353e8759aee",
"assets/assets/person/default/eatingmeal3.jpg": "b932808296b182f5ebbf8648a2e17739",
"assets/assets/person/default/head1.jpg": "1c1a2362bd551ca890f3317687bc860a",
"assets/assets/person/default/head2.jpg": "2c6f5b98f1253744233f66b3240918fb",
"assets/assets/person/default/head3.jpg": "de7455f4676fe00db1c1e2b78079175f",
"assets/assets/person/default/headache1.jpg": "87fc868fd4ced1429af08bda2d98a031",
"assets/assets/person/default/headache2.jpg": "70bb44d058399ded2855754cca1615b9",
"assets/assets/person/default/headache3.jpg": "17a000dc07c5e6f0ad23a132438c6236",
"assets/assets/person/default/hungry1.jpg": "03fd18df63cf9e254f34baa20789d74d",
"assets/assets/person/default/hungry2.jpg": "b9b05a83cf7572ca90d78802ec30296d",
"assets/assets/person/default/hungry3.jpg": "8cc4d1dc87b3354a01792f4684e17440",
"assets/assets/person/default/jindan_armsick1.jpg": "46eae967f519e73c4eaca816f51c9e67",
"assets/assets/person/default/jindan_armsick10.jpg": "79db06008084987d9eb33e53899d1ee2",
"assets/assets/person/default/jindan_armsick11.jpg": "ad52d3bced7106b491649f542ca1b181",
"assets/assets/person/default/jindan_armsick12.jpg": "11ab222e48f40d872a56a0cd0039541f",
"assets/assets/person/default/jindan_armsick13.jpg": "092c4332e3a57168c60eaa3fe5760224",
"assets/assets/person/default/jindan_armsick16.jpg": "18cbfd9d0131ce0ce59affe7245ea707",
"assets/assets/person/default/jindan_armsick3.jpg": "bd64a6f4c244dde3df69f5c944375e77",
"assets/assets/person/default/jindan_armsick4.jpg": "88cd273662beb0c395ec62b4e60e9a8a",
"assets/assets/person/default/jindan_armsick5.jpg": "940303a75cfc2025dcd2404496458be1",
"assets/assets/person/default/jindan_armsick6.jpg": "1968f8ea3d10440194fe7f6e67b6b897",
"assets/assets/person/default/jindan_armsick7.jpg": "08e20b9721f5a865f3906c5b80f6690f",
"assets/assets/person/default/jindan_armsick8.jpg": "8ebd86d785dacfab30d72868be129108",
"assets/assets/person/default/jindan_armsick9.jpg": "4ef68be8fd5325048c1037ad09b38d93",
"assets/assets/person/default/jindan_sad1.jpg": "5f0ed611cf4b464c9bcee74dd07ee3df",
"assets/assets/person/default/jindan_sad2.jpg": "5b49f9b8b99c8204efa8f98779ab335a",
"assets/assets/person/default/jindan_sad3.jpg": "8565831a2c3a014131e7a644845e60a3",
"assets/assets/person/default/jindan_stomach1.jpg": "1e939286396977ea465d59e2dbfc679b",
"assets/assets/person/default/jindan_stomach2.jpg": "68bf5681a6f68389787acb029fe57c3f",
"assets/assets/person/default/jindan_stomach3.jpg": "2e99c5871dceabca108b8dc469301fe9",
"assets/assets/person/default/leg1.jpg": "59a9bb0b897ab4c77ba93dd6563eb2f0",
"assets/assets/person/default/leg2.jpg": "8a2561db5f1cf37453cbb08521da5ef1",
"assets/assets/person/default/leg3.jpg": "ee4cceb75e68d4cc8a86c55a97ec5c22",
"assets/assets/person/default/leg4.jpg": "d220913317cc581901f42a67e6b10323",
"assets/assets/person/default/medi1.jpg": "a0da51cc883163fbab4f598403682b4f",
"assets/assets/person/default/medi2.jpg": "42b2553fc37fd16b2290f1e770aeadd3",
"assets/assets/person/default/medi3.jpg": "6b4d1c0edc5c199251e229e90a39079e",
"assets/assets/person/default/nobrush1.jpg": "fc65d753022421296a82e6a3d43f1a79",
"assets/assets/person/default/nobrush2.jpg": "788783bd9b8c1a0bd18385fa1aaa4ad6",
"assets/assets/person/default/nobrush3.jpg": "3c67a116dc93cf77e78d6fe770c71f9f",
"assets/assets/person/default/smile1.jpg": "1c65f7b7d547fb2197b2ead4610df82a",
"assets/assets/person/default/smile2.jpg": "a1997b6326564f9eb0652c11ad8b31e6",
"assets/assets/person/default/smile3.jpg": "adea9444ad5e51b7babeacf3e35ff1a1",
"assets/assets/person/default/th1.jpg": "723e74e172da23761f5717dc169f67ce",
"assets/assets/person/default/th2.jpg": "8163d38652826880fd64ab8c027e758b",
"assets/assets/person/default/th3.jpg": "7c9568c33bbc61f2f9057b9548b4d4ac",
"assets/assets/person/default/th4.jpg": "11022295862fdfcc78eed7cadb4c0fdf",
"assets/assets/person/default/tired1.jpg": "4b54a6a4ae0f6ab1c13a0f5c3e57bade",
"assets/assets/person/default/tired2.jpg": "a6c8bbe0ea2230b954f008dd161cdfe4",
"assets/assets/person/default/tired3.jpg": "10909e88034c82230d5a40702f293e6d",
"assets/assets/person/default/waist1.jpg": "0eec56d4fcb41bf2e03bf803c3f527b9",
"assets/assets/person/default/waist2.jpg": "21cf1ae993edc03906e8655302c972f5",
"assets/assets/person/default/waist3.jpg": "40df5beff62b681a2479dfd002145e23",
"assets/assets/person/default/yee1.jpg": "7d593be79781a197129d814773bbd50e",
"assets/assets/person/default/yee2.jpg": "7f8268177f50825a72cfe728ad597283",
"assets/assets/person/default/yee3.jpg": "4c5db0a7ac923bcd1b8b1e8babf5ade6",
"assets/assets/place_holder.png": "67906584562cfe06b57d99c15a470a8d",
"assets/assets/signin.png": "10bd411fb33b6edce9cce690dcaebe18",
"assets/assets/splash/splash_image.png": "5e1c855cdbb72014f0a8c1547f556b7e",
"assets/FontManifest.json": "2c4c55b5e865478180e1f245ac74b5d5",
"assets/fonts/MaterialIcons-Regular.otf": "6b7cd8a702b7e9330dea5d7b0d7568f7",
"assets/NOTICES": "3abcb829980ecd2c0eadc41cfa9fae72",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "4769f3245a24c1fa9965f113ea85ec2a",
"assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "3ca5dc7621921b901d513cc1ce23788c",
"assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "bd15a6f5239bf226a94caf74c5cd15b2",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "66177750aff65a66cb07bb44b8c6422b",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/chromium/canvaskit.js": "671c6b4f8fcc199dcc551c7bb125f239",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/skwasm.js": "694fda5704053957c2594de355805228",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "f393d3c16b631f36852323de8e583132",
"flutter_bootstrap.js": "23a6cd5fa82873a6d0eb7ab78230ae38",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "ad169cdef3e2c5ee917981cf062775d0",
"/": "ad169cdef3e2c5ee917981cf062775d0",
"main.dart.js": "306ac0266b601351aba2bde88f543dd9",
"manifest.json": "17a936398e1fa69fe3ee3ed65127fff8",
"version.json": "952e01e7a8ca09393941c7becdb8cc0a"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
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
