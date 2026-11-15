<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Middleware\SetCacheHeaders;
use Illuminate\Http\Request;
use Illuminate\Routing\Middleware\SubstituteBindings;
use Illuminate\Support\Facades\Route;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
        then: fn () => Route::middleware('static')->group(base_path('routes/static.php')),
    )
    ->withMiddleware(function (Middleware $middleware): void {
        // Guest pages the edge may cache: no session, CSRF, or cookie middleware, so
        // responses carry no Set-Cookie. Only 2xx responses get the public headers.
        $middleware->group('static', [
            SubstituteBindings::class,
            SetCacheHeaders::using('public;max_age=0;s_maxage=600;stale_while_revalidate=86400;etag'),
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->shouldRenderJsonWhen(
            fn (Request $request) => $request->is('api/*') || $request->expectsJson(),
        );
    })->create();
