/*
 * Anything that needs to be accessed from multiple files can 
 * go here. Coffeescript is scoped to the file, meaning anything 
 * you declare in coffee is not available to any other js modules.
 */

// Idle timer vars
var idleTimeoutMs = 600000 // 10 minutes
var idleWarningSec = 60    // 1 minute
