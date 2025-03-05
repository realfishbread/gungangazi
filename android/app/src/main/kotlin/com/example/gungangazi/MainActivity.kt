package com.example.gungangazi

import io.flutter.embedding.android.FlutterFragmentActivity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log
import androidx.lifecycle.lifecycleScope
import androidx.health.connect.client.HealthConnectClient
import kotlinx.coroutines.launch

class MainActivity: FlutterFragmentActivity() {  // ✅ 올바른 선언

    private lateinit var healthConnectClient: HealthConnectClient  // Health Connect 클라이언트 선언

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Health Connect 초기화
        checkHealthConnect(this)
    }

    private fun checkHealthConnect(context: Context) {
        val providerPackageName = "com.google.android.apps.healthdata"
        val availabilityStatus = HealthConnectClient.getSdkStatus(context, providerPackageName)

        if (availabilityStatus == HealthConnectClient.SDK_UNAVAILABLE) {
            Log.e("HealthConnect", "Health Connect를 사용할 수 없습니다.")
            return // Health Connect 사용 불가
        }

        if (availabilityStatus == HealthConnectClient.SDK_UNAVAILABLE_PROVIDER_UPDATE_REQUIRED) {
            Log.e("HealthConnect", "Health Connect 업데이트 필요")
            val uriString = "market://details?id=$providerPackageName&url=healthconnect%3A%2F%2Fonboarding"
            context.startActivity(
                Intent(Intent.ACTION_VIEW).apply {
                    setPackage("com.android.vending")
                    data = Uri.parse(uriString)
                    putExtra("overlay", true)
                    putExtra("callerId", context.packageName)
                }
            )
            return
        }

        // Health Connect 클라이언트 가져오기
        healthConnectClient = HealthConnectClient.getOrCreate(context)

        // 비동기 작업 실행 (권한 확인 및 요청)
        lifecycleScope.launch {
            checkPermissionsAndRun(healthConnectClient)
        }
    }

    // ✅ 권한 확인 및 요청 함수
    private suspend fun checkPermissionsAndRun(healthConnectClient: HealthConnectClient) {
        val PERMISSIONS =
            setOf(
                androidx.health.connect.client.permission.HealthPermission.getReadPermission(
                    androidx.health.connect.client.records.StepsRecord::class
                ),
                androidx.health.connect.client.permission.HealthPermission.getWritePermission(
                    androidx.health.connect.client.records.StepsRecord::class
                )
            )

        val granted = healthConnectClient.permissionController.getGrantedPermissions()
        if (granted.containsAll(PERMISSIONS)) {
            Log.d("HealthConnect", "필요한 권한이 이미 부여됨")
        } else {
            Log.e("HealthConnect", "권한이 부족합니다. 요청이 필요합니다.")
        }
    }
}
