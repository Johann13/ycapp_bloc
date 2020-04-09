import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ycapp_bloc/bloc/repo_provider.dart';
import 'package:ycapp_bloc/ui/loader/pref_data_loader.dart';
import 'package:ycapp_foundation/model/creator/creator.dart';
import 'package:ycapp_foundation/ui/loader/base/y_builder.dart';
import 'package:ycapp_foundation/ui/loader/base/y_stream_widgets.dart';

class CreatorStream extends YStreamBuilder<Creator> {
  CreatorStream({
    @required Stream<Creator> creator,
    @required YDataBuilder<Creator> builder,
    ErrorBuilder error,
    WidgetBuilder loading,
  }) : super(
          stream: creator,
          error: error,
          loading: loading,
          builder: builder,
        );
}

class CreatorListStream extends YStreamListBuilder<Creator> {
  CreatorListStream({
    @required Stream<List<Creator>> creator,
    @required YDataBuilder<List<Creator>> builder,
    ErrorBuilder error,
    WidgetBuilder empty,
    WidgetBuilder loading,
  }) : super(
          stream: creator,
          error: error,
          empty: empty,
          loading: loading,
          builder: builder,
        );
}

class CreatorWidget extends StatelessWidget {
  final String creatorId;
  final YDataBuilder<Creator> builder;
  final ErrorBuilder error;
  final WidgetBuilder loading;

  CreatorWidget({
    @required this.creatorId,
    @required this.builder,
    this.error,
    this.loading,
  });

  @override
  Widget build(BuildContext context) => CreatorStream(
        creator: RepoProvider.of(context).creatorBloc.getCreator(creatorId),
        builder: builder,
        error: error,
        loading: loading,
      );
}

class CreatorListWidget extends StatelessWidget {
  final List<String> creatorIds;
  final YDataBuilder<List<Creator>> builder;
  final ErrorBuilder error;
  final WidgetBuilder loading;
  final WidgetBuilder empty;

  CreatorListWidget({
    @required this.creatorIds,
    @required this.builder,
    this.error,
    this.loading,
    this.empty,
  });

  @override
  Widget build(BuildContext context) => CreatorListStream(
        creator:
            RepoProvider.of(context).creatorBloc.getCreatorByIds(creatorIds),
        builder: builder,
        error: error,
        loading: loading,
        empty: empty,
      );
}

class AllSubscribedCreatorWidget extends StatelessWidget {
  final YDataBuilder<List<Creator>> builder;
  final ErrorBuilder error;
  final WidgetBuilder loading;
  final WidgetBuilder empty;

  AllSubscribedCreatorWidget({
    @required this.builder,
    this.error,
    this.loading,
    this.empty,
  });

  @override
  Widget build(BuildContext context) => CreatorListWidget(
        creatorIds: RepoProvider.of(context).creatorBloc.creatorIdList,
        builder: builder,
        error: error,
        loading: loading,
        empty: empty,
      );
}

class SubscribeToCreatorStream extends StatelessWidget {
  final String creatorId;
  final YDataBuilder<bool> builder;
  final ErrorBuilder error;
  final WidgetBuilder loading;

  SubscribeToCreatorStream({
    @required this.creatorId,
    @required this.builder,
    this.error,
    this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return BoolStreamBuilder(
      stream: RepoProvider.of(context)
          .creatorBloc
          .getsCollaborationStream(creatorId),
      builder: builder,
      error: error,
      loading: loading,
    );
  }
}

class GetsCollaborationFromCreatorStream extends StatelessWidget {
  final String creatorId;
  final YDataBuilder<bool> builder;
  final ErrorBuilder error;
  final WidgetBuilder loading;

  GetsCollaborationFromCreatorStream({
    @required this.creatorId,
    @required this.builder,
    this.error,
    this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return BoolStreamBuilder(
      stream: RepoProvider.of(context)
          .creatorBloc
          .getsCollaborationStream(creatorId),
      builder: builder,
      error: error,
      loading: loading,
    );
  }
}

class GetsCollaborationInboxFromCreatorStream extends StatelessWidget {
  final String creatorId;
  final YDataBuilder<bool> builder;
  final ErrorBuilder error;
  final WidgetBuilder loading;

  GetsCollaborationInboxFromCreatorStream({
    @required this.creatorId,
    @required this.builder,
    this.error,
    this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return BoolStreamBuilder(
      stream: RepoProvider.of(context)
          .creatorBloc
          .getsCollaborationInboxStream(creatorId),
      builder: builder,
      error: error,
      loading: loading,
    );
  }
}
