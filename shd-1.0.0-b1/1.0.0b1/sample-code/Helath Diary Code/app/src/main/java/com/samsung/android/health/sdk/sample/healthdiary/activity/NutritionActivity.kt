/*
 * Copyright (C) 2024 Samsung Electronics Co., Ltd. All rights reserved
 */
package com.samsung.android.health.sdk.sample.healthdiary.activity

import android.app.AlertDialog
import android.os.Bundle
import android.view.LayoutInflater
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.DataBindingUtil
import androidx.lifecycle.ViewModelProvider
import com.samsung.android.health.sdk.sample.healthdiary.NutritionActivityBinding
import com.samsung.android.health.sdk.sample.healthdiary.R
import com.samsung.android.health.sdk.sample.healthdiary.databinding.NutritionInfoBinding
import com.samsung.android.health.sdk.sample.healthdiary.utils.AppConstants.currentDate
import com.samsung.android.health.sdk.sample.healthdiary.utils.AppConstants.minimumDate
import com.samsung.android.health.sdk.sample.healthdiary.utils.DailyIntakeCalories
import com.samsung.android.health.sdk.sample.healthdiary.utils.SwipeDetector
import com.samsung.android.health.sdk.sample.healthdiary.utils.SwipeDetector.OnSwipeEvent
import com.samsung.android.health.sdk.sample.healthdiary.utils.SwipeDetector.SwipeTypeEnum
import com.samsung.android.health.sdk.sample.healthdiary.utils.formatString
import com.samsung.android.health.sdk.sample.healthdiary.utils.showDatePickerDialogueBox
import com.samsung.android.health.sdk.sample.healthdiary.utils.showToast
import com.samsung.android.health.sdk.sample.healthdiary.viewmodel.HealthViewModelFactory
import com.samsung.android.health.sdk.sample.healthdiary.viewmodel.NutritionViewModel

class NutritionActivity : AppCompatActivity() {

    private lateinit var binding: NutritionActivityBinding
    private lateinit var nutritionViewModel: NutritionViewModel
    private var startDate = currentDate

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        nutritionViewModel = ViewModelProvider(
            this, HealthViewModelFactory(this)
        )[NutritionViewModel::class.java]

        binding = DataBindingUtil
            .setContentView<NutritionActivityBinding>(this, R.layout.nutrition)
            .apply {
                viewModel = nutritionViewModel
            }

        initializeOnClickListeners()
        setSwipeDetector()
        setNutritionDataObservers()
    }

    private fun initializeOnClickListeners() {
        binding.movePreviousDate.setOnClickListener {
            movePreviousDate()
        }

        binding.moveNextDate.setOnClickListener {
            moveNextDate()
        }

        binding.datePicker.setOnClickListener {
            showDatePickerDialogueBox(this@NutritionActivity, startDate) { newStartDate ->
                startDate = newStartDate
                if (startDate == minimumDate) {
                    binding.movePreviousDate.setColorFilter(getColor(R.color.silver))
                } else {
                    binding.movePreviousDate.setColorFilter(getColor(R.color.black))
                }
                if (newStartDate == currentDate) {
                    binding.moveNextDate.setColorFilter(getColor(R.color.silver))
                } else {
                    binding.moveNextDate.setColorFilter(getColor(R.color.black))
                }
                nutritionViewModel.readNutritionData(startDate)
            }
        }
    }

    private fun setSwipeDetector() {
        SwipeDetector(binding.scrollView).setOnSwipeListener(object : OnSwipeEvent {
            override fun swipeEventDetected(
                swipeType: SwipeTypeEnum
            ) {
                if (swipeType == SwipeTypeEnum.LEFT_TO_RIGHT) {
                    movePreviousDate()
                } else if (swipeType == SwipeTypeEnum.RIGHT_TO_LEFT) {
                    moveNextDate()
                }
            }
        })
    }

    private fun setNutritionDataObservers() {
        /**  Update nutrition UI */
        nutritionViewModel.dailyIntakeCaloriesData.observe(this) {
            updateNutritionUI(it)
            updateNutritionInfoBox(it)
        }

        /** Show toast on exception occurrence **/
        nutritionViewModel.exceptionResponse.observe(this) { message ->
            showToast(this, message)
        }
    }

    override fun onResume() {
        super.onResume()
        if (startDate == currentDate) {
            binding.moveNextDate.setColorFilter(getColor(R.color.silver))
        }
        nutritionViewModel.readNutritionData(startDate)
    }

    private fun movePreviousDate() {
        if (startDate > minimumDate) {
            startDate = startDate.minusDays(1)
            if (startDate == minimumDate) {
                binding.movePreviousDate.setColorFilter(getColor(R.color.silver))
            }
            binding.moveNextDate.setColorFilter(getColor(R.color.black))
            nutritionViewModel.readNutritionData(startDate)
        }
    }

    private fun moveNextDate() {
        if (startDate < currentDate) {
            startDate = startDate.plusDays(1)
            if (startDate == currentDate) {
                binding.moveNextDate.setColorFilter(getColor(R.color.silver))
            }
            binding.movePreviousDate.setColorFilter(getColor(R.color.black))
            nutritionViewModel.readNutritionData(startDate)
        }
    }

    private fun updateNutritionUI(dailyIntakeCalories: DailyIntakeCalories) {
        binding.run {
            breakfast.text = formatString(dailyIntakeCalories.breakfast)
            morningSnack.text = formatString(dailyIntakeCalories.morningSnack)
            lunch.text = formatString(dailyIntakeCalories.lunch)
            afternoonSnack.text = formatString(dailyIntakeCalories.afternoonSnack)
            eveningSnack.text = formatString(dailyIntakeCalories.eveningSnack)
            dinner.text = formatString(dailyIntakeCalories.dinner)
            breakfastData.text =
                titleSlicing(dailyIntakeCalories.breakfastNutritionInfo.title)
            morningSnackData.text =
                titleSlicing(dailyIntakeCalories.morningSnackNutritionInfo.title)
            lunchData.text =
                titleSlicing(dailyIntakeCalories.lunchNutritionInfo.title)
            afternoonSnackData.text =
                titleSlicing(dailyIntakeCalories.afternoonSnackNutritionInfo.title)
            eveningSnackData.text =
                titleSlicing(dailyIntakeCalories.eveningSnackNutritionInfo.title)
            dinnerData.text =
                titleSlicing(dailyIntakeCalories.dinnerNutritionInfo.title)
        }
    }

    private fun updateNutritionInfoBox(dailyIntakeCalories: DailyIntakeCalories) {
        binding.breakfastBox.setOnClickListener { _ ->
            showNutritionBox(dailyIntakeCalories.breakfastNutritionInfo)
        }
        binding.morningSnackBox.setOnClickListener { _ ->
            showNutritionBox(dailyIntakeCalories.morningSnackNutritionInfo)
        }
        binding.lunchBox.setOnClickListener { _ ->
            showNutritionBox(dailyIntakeCalories.lunchNutritionInfo)
        }
        binding.afternoonSnackBox.setOnClickListener { _ ->
            showNutritionBox(dailyIntakeCalories.afternoonSnackNutritionInfo)
        }
        binding.eveningSnackBox.setOnClickListener { _ ->
            showNutritionBox(dailyIntakeCalories.eveningSnackNutritionInfo)
        }
        binding.dinnerBox.setOnClickListener { _ ->
            showNutritionBox(dailyIntakeCalories.dinnerNutritionInfo)
        }
    }

    private fun showNutritionBox(nutritionInfo: DailyIntakeCalories.NutritionInfo) {
        val customBinding = NutritionInfoBinding.inflate(LayoutInflater.from(this))

        customBinding.let {
            it.proteinData.text = formatString(nutritionInfo.protein)
            it.totalFatData.text = formatString(nutritionInfo.totalFat)
            it.saturatedFatData.text = formatString(nutritionInfo.saturatedFat)
            it.polySaturatedFatData.text = formatString(nutritionInfo.polySaturatedFat)
            it.monoSaturatedFatData.text = formatString(nutritionInfo.monoSaturatedFat)
            it.transFatData.text = formatString(nutritionInfo.transFat)
            it.carbohydrateData.text = formatString(nutritionInfo.carbohydrate)
            it.dietaryFiberData.text = formatString(nutritionInfo.dietaryFiber)
            it.sugarData.text = formatString(nutritionInfo.sugar)
            it.cholesterolData.text = formatString(nutritionInfo.cholesterol)
            it.sodiumData.text = formatString(nutritionInfo.sodium)
            it.potassiumData.text = formatString(nutritionInfo.potassium)
            it.vitaminAData.text = formatString(nutritionInfo.vitaminA)
            it.vitaminCData.text = formatString(nutritionInfo.vitaminC)
            it.calciumData.text = formatString(nutritionInfo.calcium)
            it.ironData.text = formatString(nutritionInfo.iron)
        }

        AlertDialog.Builder(this)
            .setTitle(R.string.nutrition_info)
            .setView(customBinding.root)
            .create()
            .show()
    }

    private fun titleSlicing(title: String): String = title.slice(0..(title.length - 3))
}
