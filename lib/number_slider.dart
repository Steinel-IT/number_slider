library number_slider;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:infinite_listview/infinite_listview.dart';

class NumberSlider extends StatefulWidget {
  const NumberSlider({
    Key? key,
    required this.text,
    this.minValue,
    this.startValue,
    this.maxValue,
    this.color,
    this.borderColor,
    this.backgroundColor,
    required this.icon,
    this.borderRadius,
    this.controller,
    this.onChange,
  }) : super(key: key);

  final String text;

  final Color? color;

  final Color? borderColor;

  final Color? backgroundColor;

  final IconData icon;

  final int? minValue;

  final int? startValue;

  final int? maxValue;

  final BorderRadius? borderRadius;

  final InfiniteScrollController? controller;

  final ValueChanged<int>? onChange;

  @override
  _NumberSliderState createState() => _NumberSliderState();
}

class _NumberSliderState extends State<NumberSlider> {
  ///Variables for Controller
  InfiniteScrollController? _controller;

  InfiniteScrollController get _effectiveController => widget.controller ?? _controller!;

  ///Variables for Height
  GlobalKey _globalKey = GlobalKey();
  double height = 0.0;

  ///Variables for Values
  var _count = ValueNotifier(0);
  int _preValue = 0;

  ///Variables for Visibility
  var _vis = ValueNotifier(false);
  bool _onIt = true;
  bool _onScrolling = false;

  @override
  void initState() {
    if (widget.controller == null) _controller = InfiniteScrollController();
    if (widget.startValue != null) _count.value = widget.startValue!;

    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      height = _globalKey.currentContext?.size?.height ?? 50;
      setState(() {});
    });
    super.initState();
  }

  ///scroll Calculation
  void updateScroll(double? delta) {
    double d = delta ?? 0;
    if (d % 100 == 0) d /= -10;
    _preValue += d.floor();
    if (_preValue >= 10) {
      int max = widget.maxValue ?? 0;
      if (widget.maxValue == null || max > _count.value) _count.value++;
      if (widget.onChange != null) widget.onChange!(_count.value);
      _preValue = 0;
    } else if (_preValue <= -10) {
      int min = widget.minValue ?? 0;
      if (widget.minValue == null || min < _count.value) _count.value--;
      if (widget.onChange != null) widget.onChange!(_count.value);
      _preValue = 0;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Container(
            key: _globalKey,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              border: Border(
                top: BorderSide(color: widget.borderColor ?? Colors.black),
                left: BorderSide(color: widget.borderColor ?? Colors.black),
                bottom: BorderSide(color: widget.borderColor ?? Colors.black),
                right: BorderSide(color: widget.borderColor ?? Colors.black),
              ),
              borderRadius: widget.borderRadius,
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.text,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Icon(
                            widget.icon,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: ValueListenableBuilder<int>(
                              valueListenable: _count,
                              builder: (context, v, c) {
                                return Text(
                                  v.toString(),
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: widget.color ?? Theme.of(context).accentColor),
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _vis.value = true;
                  },
                  child: MouseRegion(
                    onEnter: (e) {
                      _vis.value = true;
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: widget.color ?? Theme.of(context).accentColor,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.arrow_drop_up_rounded,
                            color: Colors.white,
                          ),
                          const Icon(
                            Icons.arrow_drop_down_rounded,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _vis,
          builder: (context, v, c) {
            return Visibility(
              child: c ?? const SizedBox(),
              visible: v,
            );
          },
          child: GestureDetector(
            onTap: () {
              _onScrolling = false;
              _vis.value = false;
            },
            child: MouseRegion(
              onEnter: (_) {
                _onIt = true;
              },
              onExit: (_) {
                _onIt = false;
                if (!_onScrolling) {
                  _vis.value = false;
                }
              },
              child: NotificationListener<ScrollStartNotification>(
                onNotification: (_) {
                  _onScrolling = true;
                  return true;
                },
                child: NotificationListener<ScrollEndNotification>(
                  onNotification: (_) {
                    _onScrolling = false;
                    if (!_onIt) _vis.value = false;
                    return true;
                  },
                  child: Container(
                    width: 50,
                    height: height + 20,
                    margin: const EdgeInsets.only(top: 10, bottom: 10, right: 4),
                    decoration: BoxDecoration(
                      color: widget.color ?? Theme.of(context).accentColor,
                      borderRadius: const BorderRadius.all(Radius.circular(3)),
                      boxShadow: [
                        BoxShadow(color: widget.color ?? Theme.of(context).accentColor, blurRadius: 10, spreadRadius: -3, offset: Offset(-2, 0)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      clipBehavior: Clip.hardEdge,
                      child: NotificationListener<ScrollUpdateNotification>(
                        onNotification: (scroll) {
                          updateScroll(scroll.scrollDelta);
                          return true;
                        },
                        child: InfiniteListView.separated(
                          controller: _effectiveController,
                          itemBuilder: (context, index) {
                            if (index % 5 == 0) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 20,
                                    height: 2,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(color: Colors.white),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 12,
                                    height: 1,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(color: Colors.white),
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                          separatorBuilder: (context, index) {
                            return const SizedBox(
                              height: 8,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
