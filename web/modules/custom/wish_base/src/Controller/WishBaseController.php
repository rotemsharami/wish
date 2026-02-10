<?php

namespace Drupal\wish_base\Controller;

use Drupal\Core\Controller\ControllerBase;

class WishBaseController extends ControllerBase {

  public function page(): array {
    return [
      '#theme' => 'wish_base_page',
      '#attached' => [
        'library' => [
          'wish_base/wish_base.page',
        ],
      ],
      '#data' => [
        'title' => 'Hello from Controller',
        'message' => 'JS + CSS attached successfully.',
      ],
    ];
  }

}
