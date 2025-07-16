import 'package:flutter/material.dart';
import 'package:guruchaya/helper/colors.dart';
import 'package:guruchaya/helper/dimens.dart';
import 'package:guruchaya/helper/string.dart';


class AppDropDown extends StatefulWidget {
  dynamic selectedItem;
  List<dynamic> items;
  Function(dynamic)? onItemSelected;
  Color fillColor;
  String? prefixIcon;
  String hint;
  bool isRightArrow;
  final bool isReadOnly;

  AppDropDown(
      {required this.selectedItem,
      required this.items,
      required this.onItemSelected,
      this.fillColor = Colors.transparent,
      this.prefixIcon,
      this.hint = "",
      this.isRightArrow = true,
      this.isReadOnly = false,
      Key? key})
      : super(key: key);

  @override
  State<AppDropDown> createState() => AppDropDownState();
}

class AppDropDownState extends State<AppDropDown> {
  static AppDropDownState? _currentlyOpenDropdown;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _toggleDropdown() {
    if (widget.isReadOnly) {
      return;
    }
    if (_overlayEntry == null) {
      _currentlyOpenDropdown?.removeDropdown();
      _currentlyOpenDropdown = this;
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      removeDropdown();
    }
    setState(() {});
  }

  void removeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (_currentlyOpenDropdown == this) {
      _currentlyOpenDropdown = null;
    }if(!mounted) {
      setState(() {});
    }

  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;
    Offset offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                removeDropdown();
              },
              behavior: HitTestBehavior.translucent,
              child: Container(),
            ),
          ),
          Positioned(
            width: size.width,
            left: offset.dx,
            top: offset.dy + size.height + 4,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 4),
              child: Material(
                color: Colors.transparent,
                child: widget.items.length > 6
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: dropDownTile(),
                      )
                    : dropDownTile(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  dropDownTile() {
    return MediaQuery(
      data: MediaQueryData(
        textScaleFactor: 1.0,
      ),
      child: Container(
        padding: EdgeInsets.all(Dimens.padding_15),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(Dimens.circularRadius_12),
        ),
        child: ListView.builder(
          shrinkWrap: !(widget.items.length > 6),
          physics: widget.items.length > 6 ? const AlwaysScrollableScrollPhysics() :const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            final bool isSelected = widget.items[index] == widget.selectedItem;
            return InkWell(
              onTap: () {
                widget.onItemSelected!(widget.items[index]);
                removeDropdown();
              },
              child: Container(
                margin: EdgeInsets.only(bottom: Dimens.margin_10),
                padding:  EdgeInsets.symmetric(
                    horizontal: Dimens.padding_15,
                    vertical: Dimens.padding_8),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(Dimens.circularRadius_50),
                ),
                child: Text(
                  widget.items[index].toString(),
                  style: TextStyle(
                    fontFamily: Fonts.medium,
                    fontSize: Dimens.fontSize_14,
                    color: isSelected ? Theme.of(context).textTheme.labelMedium!.color : Theme.of(context).textTheme.labelSmall!.color,
                  ),
                ),
              ),
            );
          },
          itemCount: widget.items.length,
        ),
      ),
    );
  }

  @override
  void dispose() {
    removeDropdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            onTap: _toggleDropdown,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                      vertical: Dimens.padding_14,
                      horizontal: Dimens.padding_18),
                  decoration: BoxDecoration(
                    color: widget.fillColor,
                    border: Border.all(
                      color: primaryColor,
                    ),
                    borderRadius: BorderRadius.circular(
                        Dimens.radius_12), // Set the radius here
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.prefixIcon != null)
                        Padding(
                          padding: EdgeInsets.only(
                              right: Dimens.padding_12),
                          child: Image.asset(
                            widget.prefixIcon!,
                            height: Dimens.dimen_25,
                            width: Dimens.dimen_25,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          widget.selectedItem.toString(),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.labelSmall!.color,
                            fontSize: Dimens.fontSize_14,
                            fontFamily: Fonts.medium,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: Dimens.dimen_10,
                      ),
                      Image.asset(
                        Images.dropDown,
                        height: Dimens.height_15,
                        width: Dimens.height_15,
                        color: Theme.of(context).textTheme.labelSmall!.color,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
