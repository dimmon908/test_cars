$ ->
  $("a[data-remote]").on "ajax:complete", (e, data, status, xhr) ->
    alert '2'