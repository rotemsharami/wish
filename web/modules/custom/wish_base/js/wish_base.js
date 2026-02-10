(function (Drupal, once) {
  Drupal.behaviors.wishBaseBehavior = {
    attach: function (context) {
      once('wishBaseBtn', '.wish-base-btn', context).forEach((btn) => {
        btn.addEventListener('click', () => {
          const out = context.querySelector('.wish-base-output');
          if (out) out.textContent = 'Button clicked ✅';
        });
      });
    }
  };
})(Drupal, once);
