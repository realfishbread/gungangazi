/*
 * Copyright (C) 2024 Samsung Electronics Co., Ltd. All rights reserved
 */
package com.samsung.android.health.sdk.sample.healthdiary.viewmodel

import android.app.Activity
import androidx.databinding.ObservableField
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.samsung.android.health.sdk.sample.healthdiary.utils.AppConstants
import com.samsung.android.health.sdk.sample.healthdiary.utils.DailyIntakeCalories
import com.samsung.android.health.sdk.sample.healthdiary.utils.dateFormat
import com.samsung.android.health.sdk.sample.healthdiary.utils.formatString
import com.samsung.android.health.sdk.sample.healthdiary.utils.getExceptionHandler
import com.samsung.android.sdk.health.data.HealthDataStore
import com.samsung.android.sdk.health.data.data.HealthDataPoint
import com.samsung.android.sdk.health.data.request.DataType
import com.samsung.android.sdk.health.data.request.DataTypes
import com.samsung.android.sdk.health.data.request.LocalTimeFilter
import com.samsung.android.sdk.health.data.request.Ordering
import java.time.LocalDateTime
import kotlinx.coroutines.launch

class NutritionViewModel(private val healthDataStore: HealthDataStore, activity: Activity) :
    ViewModel() {

    private val _exceptionResponse: MutableLiveData<String> = MutableLiveData<String>()
    private val _dailyIntakeCaloriesData = MutableLiveData<DailyIntakeCalories>()
    private val exceptionHandler = getExceptionHandler(activity, _exceptionResponse)
    val exceptionResponse: LiveData<String> = _exceptionResponse
    val dailyIntakeCaloriesData: LiveData<DailyIntakeCalories> = _dailyIntakeCaloriesData
    val totalCaloriesCount = ObservableField<String>()
    val dayStartTimeAsText = ObservableField<String>()

    fun readNutritionData(dateTime: LocalDateTime) {
        dayStartTimeAsText.set(dateTime.format(dateFormat))

        val readRequest = DataTypes.NUTRITION.readDataRequestBuilder
            .setLocalTimeFilter(LocalTimeFilter.of(dateTime, dateTime.plusDays(1)))
            .setOrdering(Ordering.ASC)
            .build()

        /**  Make SDK call to read nutrition data */
        viewModelScope.launch(AppConstants.SCOPE_IO_DISPATCHERS + exceptionHandler) {
            val intakeList = healthDataStore.readData(readRequest).dataList
            processReadDataResponse(intakeList)
        }
    }

    private fun processReadDataResponse(intakeList: List<HealthDataPoint>) {
        var calories = 0f
        val dailyIntakeCalories = DailyIntakeCalories()

        intakeList.forEach { nutritionData ->
            calories += nutritionData.getValueOrDefault(DataType.NutritionType.CALORIES, 0F)
            dailyIntakeCalories.addData(
                nutritionData.getValueOrDefault(
                    DataType.NutritionType.MEAL_TYPE,
                    DataType.NutritionType.MealType.BREAKFAST
                ),
                nutritionData.getValueOrDefault(DataType.NutritionType.CALORIES, 0F),
                nutritionData.getValueOrDefault(DataType.NutritionType.TITLE, ""),
                nutritionData.getValueOrDefault(DataType.NutritionType.PROTEIN, 0F),
                nutritionData.getValueOrDefault(DataType.NutritionType.TOTAL_FAT, 0F),
                nutritionData.getValueOrDefault(DataType.NutritionType.SATURATED_FAT, 0F),
                nutritionData.getValueOrDefault(DataType.NutritionType.POLYSATURATED_FAT, 0F),
                nutritionData.getValueOrDefault(DataType.NutritionType.MONOSATURATED_FAT, 0F),
                nutritionData.getValueOrDefault(DataType.NutritionType.TRANS_FAT, 0F),
                nutritionData.getValueOrDefault(DataType.NutritionType.CARBOHYDRATE, 0F),
                nutritionData.getValueOrDefault(DataType.NutritionType.DIETARY_FIBER, 0F),
                nutritionData.getValueOrDefault(DataType.NutritionType.SUGAR, 0F),
                nutritionData.getValueOrDefault(DataType.NutritionType.CHOLESTEROL, 0F),
                nutritionData.getValueOrDefault(DataType.NutritionType.SODIUM, 0F),
                nutritionData.getValueOrDefault(DataType.NutritionType.POTASSIUM, 0F),
                nutritionData.getValueOrDefault(DataType.NutritionType.VITAMIN_A, 0F),
                nutritionData.getValueOrDefault(DataType.NutritionType.VITAMIN_C, 0F),
                nutritionData.getValueOrDefault(DataType.NutritionType.CALCIUM, 0F),
                nutritionData.getValueOrDefault(DataType.NutritionType.IRON, 0F),
            )
        }

        totalCaloriesCount.set(formatString(calories))
        _dailyIntakeCaloriesData.postValue(dailyIntakeCalories)
    }
}
