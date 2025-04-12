import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class JobFiltersWidget extends StatelessWidget {
  final List<String> experienceLevels;
  final List<String> locations;
  final List<String> industries;
  final List<String> companies;
  final int? selectedExperienceLevel;
  final String? selectedLocation;
  final String? selectedIndustry;
  final String? selectedCompany;
  final Function(String?, String?, String?, int?) onFiltersChanged;

  const JobFiltersWidget({
    Key? key,
    required this.experienceLevels,
    required this.locations,
    required this.industries,
    required this.companies,
    this.selectedExperienceLevel,
    this.selectedLocation,
    this.selectedIndustry,
    this.selectedCompany,
    required this.onFiltersChanged,
  }) : super(key: key);

  int? _mapExperienceToInt(String? experience) {
    switch (experience) {
      case 'Entry-Level':
        return 0;
      case 'Mid-Level':
        return 2;
      case 'Senior':
        return 5;
      default:
        return null;
    }
  }

  String? _mapIntToExperience(int? value) {
    switch (value) {
      case 0:
        return 'Entry-Level';
      case 2:
        return 'Mid-Level';
      case 5:
        return 'Senior';
      default:
        return null;
    }
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isDense: true,
          value: value,
          hint: Text(hint, style: TextStyle(fontSize: 12.sp)),
          onChanged: onChanged,
          items:
              items.map<DropdownMenuItem<String>>((String val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(val, style: TextStyle(fontSize: 12.sp)),
                );
              }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        child: Row(
          children: [
            // Reset Filters
            FilterChip(
              label: Text('Jobs', style: TextStyle(fontSize: 12.sp)),
              selected:
                  selectedExperienceLevel == null &&
                  selectedLocation == null &&
                  selectedIndustry == null &&
                  selectedCompany == null,
              onSelected: (_) {
                onFiltersChanged(null, null, null, null);
              },
              backgroundColor: Colors.grey.shade100,
              selectedColor: Colors.blue.shade100,
              side: const BorderSide(color: Colors.blue),
              labelStyle: const TextStyle(color: Colors.black),
            ),

            SizedBox(width: 3.w),

            // Experience Dropdown
            _buildDropdown(
              hint: 'Experience',
              value: _mapIntToExperience(selectedExperienceLevel),
              items: experienceLevels,
              onChanged: (newVal) {
                onFiltersChanged(
                  selectedLocation,
                  selectedIndustry,
                  selectedCompany,
                  _mapExperienceToInt(newVal),
                );
              },
            ),

            SizedBox(width: 3.w),

            // Location Dropdown
            _buildDropdown(
              hint: 'Location',
              value: selectedLocation,
              items: locations,
              onChanged: (newVal) {
                onFiltersChanged(
                  newVal,
                  selectedIndustry,
                  selectedCompany,
                  selectedExperienceLevel,
                );
              },
            ),

            SizedBox(width: 3.w),

            // Industry Dropdown
            _buildDropdown(
              hint: 'Industry',
              value: selectedIndustry,
              items: industries,
              onChanged: (newVal) {
                onFiltersChanged(
                  selectedLocation,
                  newVal,
                  selectedCompany,
                  selectedExperienceLevel,
                );
              },
            ),

            SizedBox(width: 3.w),

            // Company Dropdown
            _buildDropdown(
              hint: 'Company',
              value: selectedCompany,
              items: companies,
              onChanged: (newVal) {
                onFiltersChanged(
                  selectedLocation,
                  selectedIndustry,
                  newVal,
                  selectedExperienceLevel,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
