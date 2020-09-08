import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ycapp_bloc/bloc/repo_provider.dart';
import 'package:ycapp_bloc/ui/loader/pref_data_loader.dart';
import 'package:ycapp_foundation/model/channel/twitch_channel.dart';
import 'package:ycapp_foundation/ui/loader/base/y_builder.dart';
import 'package:ycapp_foundation/ui/loader/base/y_stream_widgets.dart';

class TwitchStreamBuilder extends YStreamBuilder<TwitchChannel> {
  TwitchStreamBuilder({
    @required Stream<TwitchChannel> channel,
    @required YDataBuilder<TwitchChannel> builder,
    ErrorBuilder error,
    WidgetBuilder loading,
  }) : super(
          stream: channel,
          error: error,
          loading: loading,
          builder: builder,
        );
}

class TwitchListStream extends YStreamListBuilder<TwitchChannel> {
  TwitchListStream({
    @required Stream<List<TwitchChannel>> channel,
    @required YDataBuilder<List<TwitchChannel>> builder,
    ErrorBuilder error,
    WidgetBuilder empty,
    WidgetBuilder loading,
  }) : super(
          stream: channel,
          error: error,
          empty: empty,
          loading: loading,
          builder: builder,
        );
}

class TwitchVideoListStream extends YStreamListBuilder<TwitchVideo> {
  TwitchVideoListStream({
    @required Stream<List<TwitchVideo>> videos,
    @required YDataBuilder<List<TwitchVideo>> builder,
    ErrorBuilder error,
    WidgetBuilder empty,
    WidgetBuilder loading,
  }) : super(
          stream: videos,
          error: error,
          empty: empty,
          loading: loading,
          builder: builder,
        );
}

class TwitchClipListStream extends YStreamListBuilder<TwitchClip> {
  TwitchClipListStream({
    @required Stream<List<TwitchClip>> clips,
    @required YDataBuilder<List<TwitchClip>> builder,
    ErrorBuilder error,
    WidgetBuilder empty,
    WidgetBuilder loading,
  }) : super(
          stream: clips,
          error: error,
          empty: empty,
          loading: loading,
          builder: builder,
        );
}

class TwitchWidget extends StatelessWidget {
  final String twitchId;
  final YDataBuilder<TwitchChannel> builder;
  final ErrorBuilder error;
  final WidgetBuilder loading;

  TwitchWidget({
    @required this.twitchId,
    @required this.builder,
    this.error,
    this.loading,
  });

  @override
  Widget build(BuildContext context) => TwitchStreamBuilder(
        channel: RepoProvider.of(context).twitch.getChannel(twitchId),
        builder: builder,
        error: error,
        loading: loading,
      );
}

class TwitchListWidget extends StatelessWidget {
  final List<String> twitchIds;
  final YDataBuilder<List<TwitchChannel>> builder;
  final ErrorBuilder error;
  final WidgetBuilder loading;
  final WidgetBuilder empty;

  TwitchListWidget({
    @required this.twitchIds,
    @required this.builder,
    this.error,
    this.loading,
    this.empty,
  });

  @override
  Widget build(BuildContext context) => TwitchListStream(
        channel: RepoProvider.of(context).twitch.getChannelByIds(twitchIds),
        builder: builder,
        error: error,
        loading: loading,
        empty: empty,
      );
}

class AllSubscribedTwitchWidget extends StatelessWidget {
  final YDataBuilder<List<TwitchChannel>> builder;
  final ErrorBuilder error;
  final WidgetBuilder loading;
  final WidgetBuilder empty;

  AllSubscribedTwitchWidget({
    @required this.builder,
    this.error,
    this.loading,
    this.empty,
  });

  @override
  Widget build(BuildContext context) => TwitchListStream(
        channel: RepoProvider.of(context).twitch.subscriptions.switchMap(
            (ids) => RepoProvider.of(context).twitch.getChannelByIds(ids)),
        builder: builder,
        error: error,
        loading: loading,
        empty: empty,
      );
}

class TwitchUploadsListWidget extends StatelessWidget {
  final List<String> twitchIds;
  final YDataBuilder<List<TwitchVideo>> builder;
  final ErrorBuilder error;
  final WidgetBuilder loading;

  TwitchUploadsListWidget({
    @required this.twitchIds,
    @required this.builder,
    this.error,
    this.loading,
  });

  @override
  Widget build(BuildContext context) => TwitchVideoListStream(
        videos: RepoProvider.of(context).twitch.getAllUploads(twitchIds),
        builder: builder,
        error: error,
        loading: loading,
      );
}

class TwitchArchivesListWidget extends StatelessWidget {
  final List<String> twitchIds;
  final YDataBuilder<List<TwitchVideo>> builder;
  final ErrorBuilder error;
  final WidgetBuilder loading;

  TwitchArchivesListWidget({
    @required this.twitchIds,
    @required this.builder,
    this.error,
    this.loading,
  });

  @override
  Widget build(BuildContext context) => TwitchVideoListStream(
        videos: RepoProvider.of(context).twitch.getAllArchives(twitchIds),
        builder: builder,
        error: error,
        loading: loading,
      );
}

class TwitchHighlightsListWidget extends StatelessWidget {
  final List<String> twitchIds;
  final YDataBuilder<List<TwitchVideo>> builder;
  final ErrorBuilder error;
  final WidgetBuilder loading;

  TwitchHighlightsListWidget({
    @required this.twitchIds,
    @required this.builder,
    this.error,
    this.loading,
  });

  @override
  Widget build(BuildContext context) => TwitchVideoListStream(
        videos: RepoProvider.of(context).twitch.getAllHighlights(twitchIds),
        builder: builder,
        error: error,
        loading: loading,
      );
}

class TwitchSubscribedStream extends StatelessWidget {
  final String twitchId;
  final YDataBuilder<bool> builder;
  final ErrorBuilder error;
  final WidgetBuilder loading;

  TwitchSubscribedStream({
    @required this.twitchId,
    @required this.builder,
    this.loading,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return BoolStreamBuilder(
      stream: RepoProvider.of(context).twitch.isSubscribedToStream(twitchId),
      builder: builder,
      loading: loading,
      error: error,
    );
  }
}

class TwitchNotificationStream extends StatelessWidget {
  final String twitchId;
  final YDataBuilder<bool> builder;
  final ErrorBuilder error;
  final WidgetBuilder loading;

  TwitchNotificationStream({
    @required this.twitchId,
    @required this.builder,
    this.loading,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return BoolStreamBuilder(
      stream:
          RepoProvider.of(context).twitch.getsNotificationsFromStream(twitchId),
      builder: builder,
      loading: loading,
      error: error,
    );
  }
}

class TwitchInboxStream extends StatelessWidget {
  final String twitchId;
  final YDataBuilder<bool> builder;
  final ErrorBuilder error;
  final WidgetBuilder loading;

  TwitchInboxStream({
    @required this.twitchId,
    @required this.builder,
    this.loading,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return BoolStreamBuilder(
      stream: RepoProvider.of(context).twitch.getsInboxFromStream(twitchId),
      builder: builder,
      loading: loading,
      error: error,
    );
  }
}
