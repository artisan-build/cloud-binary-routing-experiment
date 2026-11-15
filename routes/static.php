<?php

use Illuminate\Support\Facades\Route;

// Routes here use the `static` middleware group (see bootstrap/app.php): Cloud's edge
// caches their responses, so a visit can be served while the app is asleep.
// They must render the same HTML for every visitor: no @csrf, @auth, or session data.

// The render time shows whether a response came from the app or from the edge cache.
Route::get('/edge', fn () => response(
    '<!doctype html><title>edge</title><p>rendered at '.now()->toIso8601String().'</p>'
)->header('X-Rendered-At', now()->toIso8601String()));
