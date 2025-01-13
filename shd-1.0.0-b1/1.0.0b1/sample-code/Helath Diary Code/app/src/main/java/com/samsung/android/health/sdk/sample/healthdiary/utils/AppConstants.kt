/*
 * Copyright (C) 2024 Samsung Electronics Co., Ltd. All rights reserved
 */
package com.samsung.android.health.sdk.sample.healthdiary.utils

import java.time.LocalDateTime
import java.time.LocalTime
import kotlinx.coroutines.Dispatchers

object AppConstants {
    const val SUCCESS = "SUCCESS"
    const val WAITING = "WAITING"
    const val NO_PERMISSION = "NO PERMISSION"
    const val NUTRITION_ACTIVITY = 0
    const val STEP_ACTIVITY = 1
    const val HEART_RATE_ACTIVITY = 2
    const val SLEEP_ACTIVITY = 3
    const val SKIN_TEMP_UNIT = "\u2103"
    const val BLOOD_OXYGEN_UNIT = "\u0025"
    val minimumDate: LocalDateTime = LocalDateTime.of(1900, 1, 1, 0, 0)
    val currentDate: LocalDateTime = LocalDateTime.now().with(LocalTime.MIDNIGHT)
    val SCOPE_IO_DISPATCHERS = Dispatchers.IO
}
