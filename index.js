// Start point of the app
const Koa = require('koa');
const Router = require('koa-router');
const Pug = require('koa-pug');
const morgan = require('koa-morgan');
const static = require('koa-static');

// Is dev env
const isDev = 'development' == process.env.NODE_ENV

// Init modules
const app = new Koa();
const router = new Router();
const pug = new Pug(
    { app: app
    , debug: isDev
    , noCache: isDev
    , locals: { isDev, version: 'test' }
    });


// Set routes
router.get('*', (ctx, next) => {
    ctx.render('views/index');
    next();
});


// Handle errors
app.on('error', err => console.error('server error', err));


// Start listening...
app
    .use(static(__dirname + '/static'))
    .use(router.routes())
    .use(morgan('dev'))
    .listen(6400);
