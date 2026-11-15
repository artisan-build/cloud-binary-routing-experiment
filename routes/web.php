<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

// Control routes: if a request for /fast/* ever reaches Laravel, this answers
// instead of the Go binary, so the response shows whether PHP was involved.
Route::any('/fast/{any?}', fn () => response()->json([
    'served_by' => 'laravel',
    'path' => request()->path(),
])->header('X-Served-By', 'laravel'))->where('any', '.*');

Route::get('/php', fn () => response()->json([
    'served_by' => 'laravel',
    'sapi' => PHP_SAPI,
    'octane' => (bool) env('LARAVEL_OCTANE'),
])->header('X-Served-By', 'laravel'));
