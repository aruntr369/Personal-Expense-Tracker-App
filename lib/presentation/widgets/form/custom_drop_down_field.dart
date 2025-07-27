import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import '../../../core/styles/app_colors.dart';

class CustomDropdownSearch<T> extends StatelessWidget {
  final String? titleText;
  final TextStyle? titleTextStyle;
  final double? top;
  final T? value;
  final List<T> items;
  final String Function(T) itemAsString;
  final void Function(T?)? onChanged;
  final void Function(T?)? onSaved;
  final String? Function(T?)? validator;
  final double? borderRadiusvalue;
  final bool? isDense;
  final Color? borderColor;
  final bool showStar;
  final String? hint;
  final bool showSearch;
  final bool readOnly;

  const CustomDropdownSearch({
    super.key,
    this.titleText,
    this.titleTextStyle,
    this.top,
    this.value,
    required this.items,
    required this.itemAsString,
    this.borderRadiusvalue,
    this.isDense = true,
    this.borderColor,
    this.showStar = false,
    this.showSearch = true,
    this.readOnly = false,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    InputBorder border = OutlineInputBorder(
      borderSide: BorderSide(color: Palette.borderGrey),
      borderRadius: BorderRadius.circular(10),
    );
    return IgnorePointer(
      ignoring: readOnly,
      child: Container(
        margin: EdgeInsets.only(top: top ?? 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  titleText ?? "",
                  style:
                      titleTextStyle ??
                      TextStyle(
                        color: Palette.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                      ),
                ),
                (showStar)
                    ? Text(
                      "*",
                      style:
                          titleTextStyle ??
                          TextStyle(
                            fontSize: 17,
                            color: Colors.red,
                            fontWeight: FontWeight.w400,
                          ),
                    )
                    : const SizedBox(),
              ],
            ),
            SizedBox(height: 6),
            DropdownSearch<T>(
              compareFn: (item1, item2) {
                return true;
              },
              dropdownBuilder: (context, selectedItem) {
                if (selectedItem is T) {
                  return Text(
                    itemAsString(selectedItem),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Palette.black,
                    ),
                  );
                }
                return Text(
                  hint ?? "",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Palette.black,
                  ),
                );
              },
              popupProps: PopupProps.menu(
                menuProps: MenuProps(borderRadius: BorderRadius.circular(12)),
                fit: FlexFit.loose,
                itemBuilder: (context, item, isDisabled, isSelected) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Text(
                      itemAsString(item),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Palette.black,
                      ),
                    ),
                  );
                },
                emptyBuilder: (context, searchEntry) {
                  return Center(
                    child: Text(
                      "No results found",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Palette.black,
                      ),
                    ),
                  );
                },
                containerBuilder: (ctx, popupWidget) {
                  return popupWidget;
                },
                showSearchBox: showSearch,
                scrollbarProps: const ScrollbarProps(thumbVisibility: true),
                searchDelay: const Duration(milliseconds: 200),
                searchFieldProps: const TextFieldProps(
                  decoration: InputDecoration(suffixIcon: Icon(Icons.search)),
                ),
              ),
              onSaved: onSaved,
              validator: validator,
              onChanged: onChanged,
              items: (filter, loadProps) => items,
              selectedItem: value,
              itemAsString: itemAsString,
              decoratorProps: DropDownDecoratorProps(
                decoration: InputDecoration(
                  fillColor: Palette.white,
                  alignLabelWithHint: false,
                  filled: true,
                  labelStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: Palette.black,
                  ),
                  counterText: "",
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  isDense: true,
                  border: border,
                  enabledBorder: border,
                  disabledBorder: border,
                  focusedBorder: border,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
