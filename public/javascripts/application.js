$(document).ready(function() {
  $('p#yes').click(function() {
    $('form#new_user').toggle('slow');
  });

  if ($('form#new_user li.error').size() > 0) {
    $('form#new_user').show();
  }

  $("#tweets").tweet({
    username: "instalover",
    join_text: "auto",
    avatar_size: 0,
    count: 1,
    query: "#dfln",
    auto_join_text_default: "",
    auto_join_text_ed: "we",
    auto_join_text_ing: "we were",
    auto_join_text_reply: "we replied to",
    auto_join_text_url: "we were checking out",
    loading_text: "loading tweets..."
  });
});