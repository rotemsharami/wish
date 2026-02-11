<?php

namespace Drupal\wish_base\Service;

use Drupal\Core\Cache\CacheBackendInterface;
use Drupal\Core\Site\Settings;
use GuzzleHttp\ClientInterface;

class NasaApi {

  public function __construct(
    private ClientInterface $httpClient,
    private CacheBackendInterface $cache
  ) {}

  /**
   * Returns NEO feed rows for a date range (max 7 days).
   */
  public function getNeoFeedRows(string $startDate, string $endDate, int $ttl = 3600): array {
    $apiKey = (string) Settings::get('nasa_api_key', '');
    if ($apiKey === '') {
      return [
        ['date' => $startDate, 'name' => 'Missing NASA API key', 'hazardous' => '', 'diameter_m' => '', 'miss_km' => '', 'url' => ''],
      ];
    }

    $cid = "wish_base:nasa:neo_feed:$startDate:$endDate";
    if ($cache = $this->cache->get($cid)) {
      return $cache->data;
    }

    $url = 'https://api.nasa.gov/neo/rest/v1/feed';
    try {
    $res = $this->httpClient->request('GET', $url, [
        'query' => [
        'start_date' => $startDate,
        'end_date' => $endDate,
        'api_key' => $apiKey,
        ],
        'timeout' => 30,
        'connect_timeout' => 10,
        'http_errors' => false,
        'curl' => [
        CURLOPT_IPRESOLVE => CURL_IPRESOLVE_V4,
        ],
        'headers' => [
        'Accept' => 'application/json',
        'User-Agent' => 'wish-base-drupal/1.0',
        ],
    ]);
    }
    catch (\Throwable $e) {
    \Drupal::logger('wish_base')->error('NASA API exception: @msg', ['@msg' => $e->getMessage()]);
    return [];
    }

    $data = json_decode((string) $res->getBody(), true);
    $rows = [];

    $objectsByDate = $data['near_earth_objects'] ?? [];
    foreach ($objectsByDate as $date => $objects) {
      foreach ($objects as $o) {
        $haz = !empty($o['is_potentially_hazardous_asteroid']) ? 'Yes' : 'No';

        $diamMin = $o['estimated_diameter']['meters']['estimated_diameter_min'] ?? null;
        $diamMax = $o['estimated_diameter']['meters']['estimated_diameter_max'] ?? null;
        $diamAvg = ($diamMin !== null && $diamMax !== null) ? round(($diamMin + $diamMax) / 2, 1) : '';

        $approach = $o['close_approach_data'][0] ?? [];
        $missKm = isset($approach['miss_distance']['kilometers']) ? round((float) $approach['miss_distance']['kilometers']) : '';

        $rows[] = [
          'date' => $date,
          'name' => $o['name'] ?? '',
          'hazardous' => $haz,
          'diameter_m' => $diamAvg,
          'miss_km' => $missKm,
          'url' => $o['nasa_jpl_url'] ?? '',
        ];
      }
    }

    // Cache for 1 hour by default.
    $this->cache->set($cid, $rows, time() + $ttl);

    return $rows;
  }

}
