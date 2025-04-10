import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class JobFiltersWidget extends StatelessWidget {
  final List<String> experienceLevels;
  final List<String> companies;
  final List<String> salaryRanges;
  final String? selectedExperienceLevel;
  final String? selectedCompany;
  final String? selectedSalaryRange;
  final Function(String?, String?, String?) onFiltersChanged;

  const JobFiltersWidget({
    Key? key,
    required this.experienceLevels,
    required this.companies,
    required this.salaryRanges,
    this.selectedExperienceLevel,
    this.selectedCompany,
    this.selectedSalaryRange,
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        child: Row(
          children: [
            // Jobs Filter Chip (resets all filters when selected)
            FilterChip(
              label: Text('Jobs', style: TextStyle(fontSize: 14.sp)),
              selected:
                  selectedExperienceLevel == null &&
                  selectedCompany == null &&
                  selectedSalaryRange == null,
              onSelected: (bool value) {
                onFiltersChanged(null, null, null); // Properly reset filters
              },
            ),

            SizedBox(width: 2.w),

            // Experience Level Dropdown
            DropdownButton<String>(
              value: selectedExperienceLevel,
              hint: Text('Experience Level', style: TextStyle(fontSize: 14.sp)),
              onChanged: (String? newValue) {
                onFiltersChanged(
                  newValue!,
                  selectedCompany,
                  selectedSalaryRange,
                );
              },
              items:
                  experienceLevels.map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(fontSize: 14.sp)),
                    );
                  }).toList(),
            ),
            SizedBox(width: 2.w),

            // Company Dropdown
            DropdownButton<String>(
              value: selectedCompany,
              hint: Text('Company', style: TextStyle(fontSize: 14.sp)),
              onChanged: (String? newValue) {
                onFiltersChanged(
                  selectedExperienceLevel!,
                  newValue,
                  selectedSalaryRange,
                );
              },
              items:
                  companies.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(fontSize: 14.sp)),
                    );
                  }).toList(),
            ),
            SizedBox(width: 2.w),

            // Salary Range Dropdown
            DropdownButton<String>(
              value: selectedSalaryRange,
              hint: Text('Salary Range', style: TextStyle(fontSize: 14.sp)),
              onChanged: (String? newValue) {
                onFiltersChanged(
                  selectedExperienceLevel!,
                  selectedCompany,
                  newValue,
                );
              },
              items:
                  salaryRanges.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(fontSize: 12.sp)),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
