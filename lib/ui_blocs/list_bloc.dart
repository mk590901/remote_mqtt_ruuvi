// list_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../gui_adapter/service_adapter.dart';

// Events
abstract class ListEvent {}

class SelectOptionEvent extends ListEvent {
  final String option;
  SelectOptionEvent(this.option);
}

// States
class ListState {
  final String selectedOption;

  ListState({required this.selectedOption,});

  ListState copyWith({String? selectedOption, List<String>? items}) {
    return ListState(
      selectedOption: selectedOption ?? this.selectedOption,
    );
  }
}

// BLoC
class ListBloc extends Bloc<ListEvent, ListState> {

  static final List<String> items = [
    "R09_0803",
    "COLMI R12_4503",
    "R99 5C86",
  ];

  ListBloc()
    : super(
        ListState(
          selectedOption: items[0],
        ),
      ) {

    ServiceAdapter.instance()?.setListBloc(this);

    on<SelectOptionEvent>((event, emit) {
      emit(state.copyWith(selectedOption: event.option));
      ServiceAdapter.instance()?.setDiscoveryDeviceName(event.option);
    });

  }
}
