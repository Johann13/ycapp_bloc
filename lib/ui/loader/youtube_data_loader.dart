import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ycapp_bloc/bloc/repo_provider.dart';
import 'package:ycapp_bloc/ui/loader/pref_data_loader.dart';
import 'package:ycapp_foundation/model/channel/youtube_channel.dart';
import 'package:ycapp_foundation/ui/loader/base/y_builder.dart';
import 'package:ycapp_foundation/ui/loader/base/y_stream_widgets.dart';

class YoutubeStream extends YStreamBuilder<YoutubeChannel> {
  YoutubeStream({
    @required Stream<YoutubeChannel> channel,
    @required YDataBuilder<YoutubeChannel> builder,
    ErrorBuilder error,
    WidgetBuilder loading,
  }) : super(
          stream: channel,
          error: error,
          loading: loading,
          builder: builder,
        );
}

class YoutubeListStream extends YStreamListBuilder<YoutubeChannel> {
  YoutubeListStream({
    @required Stream<List<YoutubeChannel>> channel,
    @required YDataBuilder<List<YoutubeChannel>> builder,
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

class YoutubeVideoListStream extends YStreamListBuilder<Video> {
  YoutubeVideoListStream({
    @required Stream<List<Video>> channel,
    @required YDataBuilder<List<Video>> builder,
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

class YoutubeWidget extends StatelessWidget {
  final String youtubeId;
  final YDataBuilder<YoutubeChannel> builder;
  final ErrorBuilder error;
  final WidgetBuilder loading;

  YoutubeWidget({
    @required this.youtubeId,
    @required this.builder,
    this.error,
    this.loading,
  });

  @override
  Widget build(BuildContext context) => YoutubeStream(
        channel: RepoProvider.of(context).youtubeBloc.getChannel(youtubeId),
        builder: builder,
        error: error,
        loading: loading,
      );
}

class YoutubeVideoWidget extends StatelessWidget {
  final String videoId;
  final YDataBuilder<Video> builder;
  final WidgetBuilder loading;
  final ErrorBuilder error;

  YoutubeVideoWidget({
    @required this.videoId,
    this.builder,
    this.loading,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return YStreamBuilder<Video>(
      stream: RepoProvider.of(context).youtubeBloc.getVideoStream(videoId),
      builder: builder,
      loading: loading,
      error: error,
    );
  }
}

class YoutubeListWidget extends StatelessWidget {
  final List<String> youtubeIds;
  final YDataBuilder<List<YoutubeChannel>> builder;
  final ErrorBuilder error;
  final WidgetBuilder loading;
  final WidgetBuilder empty;

  YoutubeListWidget({
    @required this.youtubeIds,
    @required this.builder,
    this.error,
    this.loading,
    this.empty,
  });

  @override
  Widget build(BuildContext context) => YoutubeListStream(
        channel:
            RepoProvider.of(context).youtubeBloc.getChannelByIds(youtubeIds),
        builder: builder,
        error: error,
        loading: loading,
        empty: empty,
      );
}

class AllSubscribedYoutubeWidget extends StatelessWidget {
  final YDataBuilder<List<YoutubeChannel>> builder;
  final ErrorBuilder error;
  final WidgetBuilder loading;
  final WidgetBuilder empty;

  AllSubscribedYoutubeWidget({
    @required this.builder,
    this.error,
    this.loading,
    this.empty,
  });

  @override
  Widget build(BuildContext context) {
    return YoutubeListStream(
      channel: RepoProvider.of(context).youtubeBloc.subscriptions.switchMap(
          (ids) => RepoProvider.of(context).youtubeBloc.getChannelByIds(ids)),
      builder: builder,
      error: error,
      loading: loading,
      empty: empty,
    );
  }
}

class YoutubeVideoListWidget extends StatelessWidget {
  final List<String> youtubeIds;
  final YDataBuilder<List<Video>> builder;
  final ErrorBuilder error;
  final WidgetBuilder loading;

  YoutubeVideoListWidget({
    @required this.youtubeIds,
    @required this.builder,
    this.error,
    this.loading,
  });

  @override
  Widget build(BuildContext context) => YoutubeVideoListStream(
        channel: RepoProvider.of(context).youtubeBloc.getAllVideos(youtubeIds),
        builder: builder,
        error: error,
        loading: loading,
      );
}

class YoutubeSubscribedStream extends StatelessWidget {
  final String youtubeId;
  final YDataBuilder<bool> builder;
  final ErrorBuilder error;
  final WidgetBuilder loading;

  YoutubeSubscribedStream({
    @required this.youtubeId,
    @required this.builder,
    this.loading,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return BoolStreamBuilder(
      stream:
          RepoProvider.of(context).youtubeBloc.isSubscribedToStream(youtubeId),
      builder: builder,
      loading: loading,
      error: error,
    );
  }
}

class YoutubeNotificationStream extends StatelessWidget {
  final String youtubeId;
  final YDataBuilder<bool> builder;
  final ErrorBuilder error;
  final WidgetBuilder loading;

  YoutubeNotificationStream({
    @required this.youtubeId,
    @required this.builder,
    this.loading,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return BoolStreamBuilder(
      stream: RepoProvider.of(context)
          .youtubeBloc
          .getsNotificationsFromStream(youtubeId),
      builder: builder,
      loading: loading,
      error: error,
    );
  }
}

class YoutubeInboxStream extends StatelessWidget {
  final String youtubeId;
  final YDataBuilder<bool> builder;
  final ErrorBuilder error;
  final WidgetBuilder loading;

  YoutubeInboxStream({
    @required this.youtubeId,
    @required this.builder,
    this.loading,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return BoolStreamBuilder(
      stream:
          RepoProvider.of(context).youtubeBloc.getsInboxFromStream(youtubeId),
      builder: builder,
      loading: loading,
      error: error,
    );
  }
}
