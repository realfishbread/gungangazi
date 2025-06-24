package com.example.gungangazi

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log
import androidx.lifecycle.lifecycleScope
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.StepsRecord
import kotlinx.coroutines.launch

class MainActivity : FlutterFragmentActivity() {

    // 채널 이름 정의
    private val CHANNEL = "com.gungangazi/health_connect"

    // Health Connect 클라이언트
    private lateinit var healthConnectClient: HealthConnectClient

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // MethodChannel 설정
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkHealthConnect" -> {
                    // Flutter에서 "checkHealthConnect"를 호출하면 실행되는 로직
                    lifecycleScope.launch {
                        checkHealthConnect(applicationContext)
                        result.success("HealthConnect Check Done")
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    /**
     * Health Connect 사용 가능 여부 확인 & 권한 체크
     */
    private fun checkHealthConnect(context: Context) {
        val providerPackageName = "com.google.android.apps.healthdata"
        // SDK 사용 가능 여부
        val availabilityStatus = HealthConnectClient.getSdkStatus(context, providerPackageName)

        when (availabilityStatus) {
            HealthConnectClient.SDK_UNAVAILABLE -> {
                Log.e("HealthConnect", "Health Connect를 사용할 수 없습니다.")
                return
            }
            HealthConnectClient.SDK_UNAVAILABLE_PROVIDER_UPDATE_REQUIRED -> {
                Log.e("HealthConnect", "Health Connect 업데이트 필요")
                // PlayStore 업데이트 페이지로 이동
                val uriString =
                    "market://details?id=$providerPackageName&url=healthconnect%3A%2F%2Fonboarding"
                context.startActivity(
                    Intent(Intent.ACTION_VIEW).apply {
                        setPackage("com.android.vending") // PlayStore
                        data = Uri.parse(uriString)
                        putExtra("overlay", true)
                        putExtra("callerId", context.packageName)
                    }
                )
                return
            }
            else -> {
                // 이용 가능 → 클라이언트 생성
                healthConnectClient = HealthConnectClient.getOrCreate(context)

                // 권한 체크 비동기 작업
                lifecycleScope.launch {
                    checkPermissionsAndRun(healthConnectClient)
                }
            }
        }
    }

    /**
     * 권한 확인 & 요청
     */
    private suspend fun checkPermissionsAndRun(healthConnectClient: HealthConnectClient) {
        val PERMISSIONS = setOf(
            HealthPermission.getReadPermission(StepsRecord::class),
            HealthPermission.getWritePermission(StepsRecord::class)
        )

        val granted = healthConnectClient.permissionController.getGrantedPermissions()
        if (granted.containsAll(PERMISSIONS)) {
            Log.d("HealthConnect", "✅ 필요한 권한이 이미 부여됨")
        } else {
            Log.e("HealthConnect", "❌ 권한 부족, 요청이 필요합니다.")
            // 실제로 권한을 요청하려면 healthConnectClient.permissionController.requestPermissions(...) 호출해야 함
        }
    }
}
