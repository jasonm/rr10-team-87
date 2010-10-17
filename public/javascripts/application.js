$(document).ready(function() {
  $('p#yes').click(function() {
    $('form#new_user').toggle('slow');
  });

  if ($('form#new_user li.error').size() > 0) {
    $('form#new_user').show();
  }
});