// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';

import 'package:api_client/api_client.dart';
import 'package:game_domain/game_domain.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockApiClient extends Mock implements ApiClient {}

class _MockResponse extends Mock implements http.Response {}

void main() {
  group('LeaderboardResource', () {
    late ApiClient apiClient;
    late http.Response response;
    late LeaderboardResource resource;

    setUp(() {
      apiClient = _MockApiClient();
      response = _MockResponse();

      resource = LeaderboardResource(apiClient: apiClient);
    });

    group('getLeaderboardResults', () {
      setUp(() {
        when(() => apiClient.get(any())).thenAnswer((_) async => response);
      });

      test('makes the correct call ', () async {
        final leaderboardPlayer = LeaderboardPlayer(
          userId: 'id',
          score: 10,
          initials: 'TST',
        );

        when(() => response.statusCode).thenReturn(HttpStatus.ok);
        when(() => response.body).thenReturn(
          jsonEncode(
            {
              'leaderboardPlayers': [leaderboardPlayer.toJson()],
            },
          ),
        );

        final results = await resource.getLeaderboardResults();

        expect(results, equals([leaderboardPlayer]));
      });

      test('throws ApiClientError when request fails', () async {
        when(() => response.statusCode)
            .thenReturn(HttpStatus.internalServerError);
        when(() => response.body).thenReturn('Oops');

        await expectLater(
          resource.getLeaderboardResults,
          throwsA(
            isA<ApiClientError>().having(
              (e) => e.cause,
              'cause',
              equals(
                'GET /leaderboard/results returned status 500 with the following response: "Oops"',
              ),
            ),
          ),
        );
      });

      test('throws ApiClientError when request response is invalid', () async {
        when(() => response.statusCode).thenReturn(HttpStatus.ok);
        when(() => response.body).thenReturn('Oops');

        await expectLater(
          resource.getLeaderboardResults,
          throwsA(
            isA<ApiClientError>().having(
              (e) => e.cause,
              'cause',
              equals(
                'GET /leaderboard/results returned invalid response "Oops"',
              ),
            ),
          ),
        );
      });
    });

    group('getInitialsBlacklist', () {
      setUp(() {
        when(() => apiClient.get(any())).thenAnswer((_) async => response);
      });

      test('gets initials blacklist', () async {
        const blacklist = ['WTF'];

        when(() => response.statusCode).thenReturn(HttpStatus.ok);
        when(() => response.body).thenReturn(jsonEncode({'list': blacklist}));
        final result = await resource.getInitialsBlacklist();

        expect(result, equals(blacklist));
      });

      test('gets empty blacklist if endpoint not found', () async {
        const emptyList = <String>[];

        when(() => response.statusCode).thenReturn(HttpStatus.notFound);
        final result = await resource.getInitialsBlacklist();

        expect(result, equals(emptyList));
      });

      test('throws ApiClientError when request fails', () async {
        when(() => response.statusCode)
            .thenReturn(HttpStatus.internalServerError);
        when(() => response.body).thenReturn('Oops');

        await expectLater(
          resource.getInitialsBlacklist,
          throwsA(
            isA<ApiClientError>().having(
              (e) => e.cause,
              'cause',
              equals(
                'GET /leaderboard/initials_blacklist returned status 500 with the following response: "Oops"',
              ),
            ),
          ),
        );
      });

      test('throws ApiClientError when request response is invalid', () async {
        when(() => response.statusCode).thenReturn(HttpStatus.ok);
        when(() => response.body).thenReturn('Oops');

        await expectLater(
          resource.getInitialsBlacklist,
          throwsA(
            isA<ApiClientError>().having(
              (e) => e.cause,
              'cause',
              equals(
                'GET /leaderboard/initials_blacklist returned invalid response "Oops"',
              ),
            ),
          ),
        );
      });
    });

    group('addLeaderboardPlayer', () {
      final leaderboardPlayer = LeaderboardPlayer(
        userId: 'id',
        score: 10,
        initials: 'TST',
      );

      setUp(() {
        when(() => apiClient.post(any(), body: any(named: 'body')))
            .thenAnswer((_) async => response);
      });

      test('makes the correct call', () async {
        when(() => response.statusCode).thenReturn(HttpStatus.noContent);
        await resource.addLeaderboardPlayer(
          leaderboardPlayer: leaderboardPlayer,
        );

        verify(
          () => apiClient.post(
            '/game/leaderboard/initials',
            body: jsonEncode(leaderboardPlayer.toJson()),
          ),
        ).called(1);
      });

      test('throws ApiClientError when request fails', () async {
        when(() => response.statusCode)
            .thenReturn(HttpStatus.internalServerError);
        when(() => response.body).thenReturn('Oops');

        await expectLater(
          () => resource.addLeaderboardPlayer(
            leaderboardPlayer: leaderboardPlayer,
          ),
          throwsA(
            isA<ApiClientError>().having(
              (e) => e.cause,
              'cause',
              equals(
                'POST /leaderboard/initials returned status 500 with the following response: "Oops"',
              ),
            ),
          ),
        );
      });
    });

    group('createScore', () {
      setUp(() {
        when(() => apiClient.post(any(), body: any(named: 'body')))
            .thenAnswer((_) async => response);
      });

      test('makes the correct call', () async {
        when(() => response.statusCode).thenReturn(HttpStatus.created);
        await resource.createScore(
          initials: 'TST',
          mascot: Mascots.dino,
        );

        verify(
          () => apiClient.post(
            '/game/create_score',
            body: jsonEncode({
              'initials': 'TST',
              'mascot': 'dino',
            }),
          ),
        ).called(1);
      });

      test('throws ApiClientError when request fails', () async {
        when(() => response.statusCode)
            .thenReturn(HttpStatus.internalServerError);
        when(() => response.body).thenReturn('Oops');

        await expectLater(
          () => resource.createScore(initials: 'TST', mascot: Mascots.dino),
          throwsA(
            isA<ApiClientError>().having(
              (e) => e.cause,
              'cause',
              equals(
                'POST /game/create_score returned status 500 '
                'with the following response: "Oops"',
              ),
            ),
          ),
        );
      });
    });
  });
}
