/*
 * Copyright (C) 2024 Samsung Electronics Co., Ltd. All rights reserved
 */
package com.samsung.android.health.sdk.sample.healthdiary.activity

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.DataBindingUtil
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.LinearLayoutManager
import com.samsung.android.health.sdk.sample.healthdiary.HeartRateActivityBinding
import com.samsung.android.health.sdk.sample.healthdiary.R
import com.samsung.android.health.sdk.sample.healthdiary.adapters.HeartRateAdapter
import com.samsung.android.health.sdk.sample.healthdiary.utils.AppConstants.currentDate
import com.samsung.android.health.sdk.sample.healthdiary.utils.AppConstants.minimumDate
import com.samsung.android.health.sdk.sample.healthdiary.utils.SwipeDetector
import com.samsung.android.health.sdk.sample.healthdiary.utils.SwipeDetector.OnSwipeEvent
import com.samsung.android.health.sdk.sample.healthdiary.utils.SwipeDetector.SwipeTypeEnum
import com.samsung.android.health.sdk.sample.healthdiary.utils.showDatePickerDialogueBox
import com.samsung.android.health.sdk.sample.healthdiary.utils.showToast
import com.samsung.android.health.sdk.sample.healthdiary.viewmodel.HealthViewModelFactory
import com.samsung.android.health.sdk.sample.healthdiary.viewmodel.HeartRateViewModel

class HeartRateActivity : AppCompatActivity() {

    private lateinit var binding: HeartRateActivityBinding
    private lateinit var heartRateAdapter: HeartRateAdapter
    private lateinit var heartRateViewModel: HeartRateViewModel
    private var startDate = currentDate

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        heartRateViewModel = ViewModelProvider(
            this, HealthViewModelFactory(this)
        )[HeartRateViewModel::class.java]

        heartRateAdapter = HeartRateAdapter()

        binding = DataBindingUtil
            .setContentView<HeartRateActivityBinding>(this, R.layout.heart_rate)
            .apply {
                viewModel = heartRateViewModel
                heartRateList.layoutManager = LinearLayoutManager(this@HeartRateActivity)
                heartRateList.adapter = heartRateAdapter
            }

        initializeOnClickListeners()
        setSwipeDetector()
        setHeartRateDataObservers()
    }

    private fun initializeOnClickListeners() {
        binding.movePreviousDate.setOnClickListener {
            movePreviousDate()
        }

        binding.moveNextDate.setOnClickListener {
            moveNextDate()
        }

        binding.datePicker.setOnClickListener {
            showDatePickerDialogueBox(this@HeartRateActivity, startDate) { newStartDate ->
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
                heartRateViewModel.readHeartRateData(startDate)
            }
        }
    }

    private fun setSwipeDetector() {
        SwipeDetector(binding.heartRateList).setOnSwipeListener(object : OnSwipeEvent {
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

    private fun setHeartRateDataObservers() {
        /**  Update heart rate UI */
        heartRateViewModel.dailyHeartRate.observe(this) {
            heartRateAdapter.updateList(it)
        }

        /** Show toast on exception occurrence **/
        heartRateViewModel.exceptionResponse.observe(this) { message ->
            showToast(this, message)
        }
    }

    override fun onResume() {
        super.onResume()
        if (startDate == currentDate) {
            binding.moveNextDate.setColorFilter(getColor(R.color.silver))
        }
        heartRateViewModel.readHeartRateData(startDate)
    }

    private fun movePreviousDate() {
        if (startDate > minimumDate) {
            startDate = startDate.minusDays(1)
            if (startDate == minimumDate) {
                binding.movePreviousDate.setColorFilter(getColor(R.color.silver))
            }
            binding.moveNextDate.setColorFilter(getColor(R.color.black))
            heartRateViewModel.readHeartRateData(startDate)
        }
    }

    private fun moveNextDate() {
        if (startDate < currentDate) {
            startDate = startDate.plusDays(1)
            if (startDate == currentDate) {
                binding.moveNextDate.setColorFilter(getColor(R.color.silver))
            }
            binding.movePreviousDate.setColorFilter(getColor(R.color.black))
            heartRateViewModel.readHeartRateData(startDate)
        }
    }
}
