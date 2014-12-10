#import "AppDelegate.h"

@implementation AppDelegate

NSThread *thread;
NSString* DownloadPath;
NSMutableSet* Bandwidth;
NSArray* http;
NSArray* allowedDomains;
NSArray* binExtentions;
NSArray* imageExtentions;
NSArray* txtExtentions;
NSArray* jsExtentions;
NSArray* wixExtentions;
NSArray* wixTags;
NSArray* wixTagsURL;
NSString* skinURL;
NSString* webURL;
NSString* wixappsURL;
NSString* coreURL;
NSString* mediaURL;
NSTask* HTTPServer;

- (id) init
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:nil];
    return self;
}

- (void)windowWillClose:(NSNotification *)notification
{
    [HTTPServer terminate];
    [NSApp terminate:self];
}

-(NSString*)downloadFile:(NSString*)url
{
    NSLog(@"download file path = %@",url);
    BOOL allow = TRUE;
//    for(int i = 0; i < [allowedDomains count]; i++)
//    {
//        if ([url rangeOfString:[allowedDomains objectAtIndex:i]].location != NSNotFound)
//        {
//            allow = TRUE;
//            break;
//        }
//    }
    
    
    if(allow && ![Bandwidth containsObject:url])
    {
        [Bandwidth addObject:url];
        //[self Debug:[NSString stringWithFormat:@"Downloading URL: %@", url]];
        
        NSHTTPURLResponse *urlResponse = nil;
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        //Fool's day incoming folks
        [request setHTTPMethod:@"GET"];
        if([[agent stringValue] isEqualToString:@"Internet Explorer"])
        {
            [request addValue:@"Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1)" forHTTPHeaderField: @"User-Agent"];
        }
        else
        {
            [request addValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9) Gecko/20100101 Firefox/25.0" forHTTPHeaderField: @"User-Agent"];
        }
        //Usually a good idea, as a security measure some files can be protected if no refferer
        //http://en.wikipedia.org/wiki/HTTP_referer
        [request addValue:url forHTTPHeaderField: @"Referer"];
        
        NSData *indexData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:nil];
        
        if ([urlResponse statusCode] == 200)
        {
            //[Bandwidth addObject:url];
            return [[NSString alloc] initWithData:indexData encoding:NSUTF8StringEncoding];
        }
        else  if ([urlResponse statusCode] == 301)
        {
            [self Debug:[NSString stringWithFormat:@"302 Moved > %@", [[NSString alloc] initWithData:indexData encoding:NSUTF8StringEncoding]]];
            //TODO catch "Server:" reply
            //_api/dynamicmodel
        }
        else
        {
            //[self Debug:[NSString stringWithFormat:@"Downloading ERROR (%ld): %@", [urlResponse statusCode], url]];
        }
    }
    return NULL;
}

- (NSData*) ServerPWN
{
    return NULL;
}

-(void)startThread
{
    NSError * error = nil;
    
    //==== Propriotery to wix.com ======
    allowedDomains = [NSArray arrayWithObjects: @"ifixit.com", [site stringValue], nil];
    wixExtentions = [NSArray arrayWithObjects: @"wysiwyg", @"skins", @"core", @"web", @"wixapps", nil];
    //==================================
    
    http = [NSArray arrayWithObjects: @"http://", @"https://", nil];
    binExtentions = [NSArray arrayWithObjects: @"ico", @"mp3", @"swf", @"html", @"htm", nil];
    txtExtentions = [NSArray arrayWithObjects: @"js", @"json", @"z", @"css", nil];
    jsExtentions = [NSArray arrayWithObjects: @"url", @"uri",  @"background-image:url", @"background:url", @"iconUrl", nil];
    imageExtentions = [NSArray arrayWithObjects: @"png", @"jpg", @"jpeg", @"gif", @"wix_mp" , nil]; //wix_mp = png
    
    DownloadPath = [NSString stringWithFormat:@"%@/Downloads/%@",NSHomeDirectory(),[[domain stringValue] stringByReplacingOccurrencesOfString:@"http://" withString:@""]];
    
    NSString *indexHTML = [self downloadFile:[site stringValue]];
//    NSString *indexAdHeader = [[NSString alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Resources/adheader.html",[[NSBundle mainBundle] bundlePath]] encoding:NSUTF8StringEncoding error:&error];
//    NSString *indexAdFooter = [[NSString alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Resources/adfooter.html",[[NSBundle mainBundle] bundlePath]] encoding:NSUTF8StringEncoding error:&error];
//    NSString *indexSEO = [[NSString alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Resources/seo.html",[[NSBundle mainBundle] bundlePath]] encoding:NSUTF8StringEncoding error:&error];
    
    //Prevent ":" in the directory name as port#
    DownloadPath = [DownloadPath stringByReplacingOccurrencesOfString:@":" withString:@"-"];
    [[NSFileManager defaultManager] createDirectoryAtPath:DownloadPath withIntermediateDirectories:NO attributes:nil error:&error];
    
//    indexHTML = [indexHTML stringByReplacingOccurrencesOfString:indexAdHeader withString:@""]; //Remove Ad Header
//    indexHTML = [indexHTML stringByReplacingOccurrencesOfString:indexAdFooter withString:@""]; //Remove Ad Footer
    
    //===================================
    //Add IE support Thanks to: Zocker-3001
//    NSString *indexIE = [[NSString alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Resources/html5shiv.html",[[NSBundle mainBundle] bundlePath]] encoding:NSUTF8StringEncoding error:&error];
//    indexHTML = [indexHTML stringByReplacingOccurrencesOfString:@"</head>" withString:[NSString stringWithFormat:@"%@\n</head>",indexIE]];
//    NSData* webBinary = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://html5shiv.googlecode.com/svn/trunk/html5.js"]];
//    [webBinary writeToFile:[NSString stringWithFormat:@"%@/html5.js",DownloadPath] atomically:YES];
    //===================================
    
//    if ([seo state] == NSOnState) //Enable SEO
//    {
//        indexHTML = [indexHTML stringByReplacingOccurrencesOfString:indexSEO withString:@""];
//    }
    
    //Save original
    [indexHTML writeToFile:[NSString stringWithFormat:@"%@/%@",DownloadPath,[indexHTML stringByReplacingOccurrencesOfString:@"/" withString:@"."]] atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    //Yes Son! split it
    NSArray *jsonHTTP = [indexHTML componentsSeparatedByString: @"\""];
    [progress setMaxValue:(int)[jsonHTTP count]];
    
    NSMutableArray *urlArray = [[NSMutableArray alloc]init];
    //==== Propriotery to wix.com ======
    for(int i = 0; i < [jsonHTTP count]; i++)  //Get static URLs dynamically
    {
//        NSString *strip = [jsonHTTP objectAtIndex:i];
//        strip = [strip stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//        NSLog(strip);
//        if ([strip isEqualToString:@"<a href="])
//        {
           NSString *str  = [jsonHTTP objectAtIndex:i];
            if([str length] > 7){
                
                if ([str rangeOfString:@"/Device/"].location != NSNotFound) {
//                    NSLog(str);
                    [urlArray addObject:str];
                }
            }
//        }
        
    }
    
//    if(!wixappsURL)
//    {
//        NSAlert *alert = [[NSAlert alloc] init];
//        [alert addButtonWithTitle:@"OK"];
//        [alert setMessageText:@"Website you are trying to download is not a wix.com design"];
//        [alert setAlertStyle:NSWarningAlertStyle];
//        [alert runModal];
//    }
//    else
//    {
        wixTags = [NSArray arrayWithObjects: @"[tdr]",@"[baseThemeDir]" @"[webThemeDir]", @"[themeDir]", @"[ulc]", @"SKIN_ICON_PATH+", nil];
        wixTagsURL = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%@/images/wysiwyg/core/themes/base/",skinURL], [NSString stringWithFormat:@"%@/images/wysiwyg/core/themes/base/",skinURL], @"/", @"/", @"/", @"/", nil];
        
        //http://static.parastorage.com/services/skins/2.648.1/images/wysiwyg/core/themes/base/shadowbottom.png
        //TODO: Wireshark these out ...find the URLS
        //[tdr],[baseThemeDir]      =   BASE_THEME_DIRECTORY
        //[themeDir]                =   THEME_DIRECTORY
        //[webThemeDir]             =   WEB_THEME_DIRECTORY
        //==================================
        
        for(int i = 0; i < [urlArray count]; i++)
        {
            NSString *who = [urlArray objectAtIndex:i];
            if ([who rangeOfString:@"/Device/"].location != NSNotFound && ![who isEqualToString:@"/Device/Edit/Phone"] && ![who isEqualToString:@"/Device/History/Phone"] && [who rangeOfString:@"/Answers/"].location == NSNotFound && [who rangeOfString:@"ifixit"].location == NSNotFound && [who rangeOfString:@"/Device/Phone"].location == NSNotFound && [who rangeOfString:@"/Device/iPhone"].location == NSNotFound) //pick only url and avoid comments
            {
                if([[NSThread currentThread] isCancelled])
                    [NSThread exit];
                
                //===================================
                NSString* fileDownload = [NSString stringWithFormat:@"%@%@",@"http://www.ifixit.com",[urlArray objectAtIndex:i]];
                NSArray* domainRoot = [[fileDownload stringByReplacingOccurrencesOfString:@"http://" withString:@""] componentsSeparatedByString: @"/"];
                
                NSString* dirRoot = [self pathFromURL:fileDownload];
                
                [self downloadAndSaveLocal:fileDownload continue:YES more:NO];
            }
            
        }
        return;
        //===================================
        //Pickup missing files (Not the best solution but it should do) Thanks to: Zocker-3001
        
        NSString* missingFiles = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Resources/dynamicmodel.txt",[[NSBundle mainBundle] bundlePath]] encoding:NSUTF8StringEncoding error:NULL];
        for (NSString *line in [missingFiles componentsSeparatedByString:@"\n"]) //read file line-by-line
        {
            if ([line rangeOfString:@"[url]"].location != NSNotFound)
            {
                line = [line stringByReplacingOccurrencesOfString:@"[url]" withString:[site stringValue]];
            }
            else if ([line rangeOfString:@"[skins]"].location != NSNotFound)
            {
                line = [line stringByReplacingOccurrencesOfString:@"[skins]" withString:skinURL];
            }
            else if ([line rangeOfString:@"[web]"].location != NSNotFound)
            {
                line = [line stringByReplacingOccurrencesOfString:@"[web]" withString:webURL];
            }
            else if ([line rangeOfString:@"[core]"].location != NSNotFound)
            {
                line = [line stringByReplacingOccurrencesOfString:@"[core]" withString:coreURL];
            }
            else if ([line rangeOfString:@"[wixapps]"].location != NSNotFound)
            {
                line = [line stringByReplacingOccurrencesOfString:@"[wixapps]" withString:wixappsURL];
            }
            
            NSArray* domainRoot = [[line stringByReplacingOccurrencesOfString:@"http://" withString:@""] componentsSeparatedByString: @"/"];
            NSString* fileRoot = [domainRoot objectAtIndex:[domainRoot count]-1];
            
            //if ([line rangeOfString:[site stringValue]].location != NSNotFound) //if own site url
            //{
            //    NSData* webBinary = [NSData dataWithContentsOfURL:[NSURL URLWithString:line]];
            //    [webBinary writeToFile:[NSString stringWithFormat:@"%@/%@/%@",DownloadPath,[self pathFromURL:line],fileRoot] atomically:YES];
            //}else{
            [self fileAnalyzer:line :fileRoot :1];
            //}
        }
        //===================================
        
        //Replace important static entries
        //===================================
        indexHTML = [indexHTML stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"\"domain\":\"%@\"",[[site stringValue] stringByReplacingOccurrencesOfString:@"http://" withString:@""]] withString:[NSString stringWithFormat:@"\"domain\":\"%@\"",[[domain stringValue] stringByReplacingOccurrencesOfString:@"http://" withString:@""]]];
        indexHTML = [indexHTML stringByReplacingOccurrencesOfString:@"\"baseDomain\":\"wix.com\"" withString:@"\"baseDomain\":\"/\""];
        //===================================
        
        if ([php state] == NSOnState)
        {
            NSString *indexPHP = [[NSString alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Resources/index.php",[[NSBundle mainBundle] bundlePath]] encoding:NSUTF8StringEncoding error:&error];
            
            [indexPHP writeToFile:[NSString stringWithFormat:@"%@/index.php",DownloadPath] atomically:YES encoding:NSUTF8StringEncoding error:&error];
            
            //Reverse-Engineered PHP Contact Form
            //===================================
            system([[NSString stringWithFormat:@"rm -r %@/common-services",DownloadPath] UTF8String]);
            [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/php",DownloadPath] withIntermediateDirectories:YES attributes:nil error:&error];
            NSString *phpContact = [[NSString alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Resources/contact.php",[[NSBundle mainBundle] bundlePath]] encoding:NSUTF8StringEncoding error:&error];
            phpContact = [phpContact stringByReplacingOccurrencesOfString:@"<user@email.com>" withString:[email stringValue]];
            [phpContact writeToFile:[NSString stringWithFormat:@"%@/php/contact.php",DownloadPath] atomically:YES encoding:NSUTF8StringEncoding error:&error];
            
            indexHTML = [indexHTML stringByReplacingOccurrencesOfString:@"\"emailServer\":\"http://assets.wix.com/common-services/notification/invoke\"" withString:[NSString stringWithFormat:@"\"emailServer\":\"%@/php/contact.php\"",[domain stringValue]]];
            //===================================
        }
        
        [indexHTML writeToFile:[NSString stringWithFormat:@"%@/index.html",DownloadPath] atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        if ([media state] == NSOnState)
        {
            NSString *htaccess = [[NSString alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Resources/htaccess",[[NSBundle mainBundle] bundlePath]] encoding:NSUTF8StringEncoding error:&error];
            if ([php state] == NSOnState)
            {
                [[NSFileManager defaultManager] copyItemAtURL:[NSString stringWithFormat:@"%@/Contents/Resources/DynamicImageResizer.php",[[NSBundle mainBundle] bundlePath]] toURL:[NSString stringWithFormat:@"%@/media/DynamicImageResizer.php",DownloadPath] error:nil];
            }
            else
            {
                htaccess = [htaccess stringByReplacingOccurrencesOfString:@"AddType application/x-httpd-php .png .jpg .wix_mp" withString:@""];
            }
            [htaccess writeToFile:[NSString stringWithFormat:@"%@/media/.htaccess",DownloadPath] atomically:YES encoding:NSUTF8StringEncoding error:&error];
        }
        
        //Cleanup empty folders
        system([[NSString stringWithFormat:@"find %@ -type d -empty -delete",DownloadPath] UTF8String]);
        
        //Remove other not interesting folders
        system([[NSString stringWithFormat:@"rm -r %@/index.json",DownloadPath] UTF8String]);
        system([[NSString stringWithFormat:@"rm -r %@/www.wix.com",DownloadPath] UTF8String]);
        system([[NSString stringWithFormat:@"rm -r %@/new",DownloadPath] UTF8String]);
        system([[NSString stringWithFormat:@"rm -r %@/create",DownloadPath] UTF8String]);
        system([[NSString stringWithFormat:@"rm -r %@/plebs",DownloadPath] UTF8String]);
        system([[NSString stringWithFormat:@"rm -r %@/portal",DownloadPath] UTF8String]);
        system([[NSString stringWithFormat:@"rm -r %@/integrations",DownloadPath] UTF8String]);
        //system([[NSString stringWithFormat:@"rm -r %@/wix-html-editor-pages-webapp",DownloadPath] UTF8String]);
        //system([[NSString stringWithFormat:@"rm -r %@/wix-public-html-renderer",DownloadPath] UTF8String]);
        
        [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[NSURL fileURLWithPath:DownloadPath]]];
//    }
    
    [self Debug:@"Downloading Finished"];
    [download setTitle:@"Download"];
    [loading stopAnimation: self];
    [loading setHidden:TRUE];
    [progress stopAnimation: self];
    
    // TODO: Looks like some "skin" graphics files are hidden deep inside java
    // do a server sweep and look for 404 requests on live Safari view.
    
    if ([[domain stringValue] rangeOfString:@"127.0.0.1:8000"].location != NSNotFound)
    {
        @try
        {
            [self Debug:@"Starting HTTPServer ..."];
            
            HTTPServer = [[NSTask alloc] init];
            NSPipe* pipe = [NSPipe pipe];
            NSFileHandle* file = [pipe fileHandleForReading];
            
            [HTTPServer setLaunchPath:@"/usr/bin/python"];
            [HTTPServer setArguments:@[@"-m", @"SimpleHTTPServer"]];
            [HTTPServer setCurrentDirectoryPath:DownloadPath];
            [HTTPServer launch];
            //[HTTPServer waitUntilExit];
            sleep(3);
            
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[[domain stringValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
            NSData* data;
            while((data=[file availableData]))
            {
                @try
                {
                    //NSArray* line = [fileRoot componentsSeparatedByString: @"/n"];
                    [self Debug:[NSString stringWithFormat:@"HTTPServer: %@", [NSString stringWithUTF8String:[data bytes]]]];
                }
                @catch (NSException *exception)
                {
                }
            }
        }
        @catch (NSException *exception)
        {
            [self Debug:[NSString stringWithFormat:@"HTTPServer Error: %@", exception]];
        }
    }
    
    [percent setStringValue:@"100 %"];
}

-(NSString*)http_correctURL:(NSString*)url
{
    url = [url stringByReplacingOccurrencesOfString:@"/./" withString:@"/"];
    while ([url rangeOfString:@"//"].location != NSNotFound)
    {
        url = [url stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
    }
    url = [url stringByReplacingOccurrencesOfString:@"http:/" withString:@"http://"];
    
    url = [url stringByReplacingOccurrencesOfString:@"http://http://" withString:@"http://"]; //Whaaa, just check.
    
    return url;
}

-(void)fileAnalyzer:(NSString*)file :(NSString*)fileRoot :(int)_level
{
    @autoreleasepool
    {
        @try //Just in case
        {
            //Apple Bug? when doing stringByDeletingLastPathComponent for URL it kicks out one of slash from http://
            file = [self http_correctURL: file];
            
            NSString* webfile = [self downloadFile:file];
            
            [self Debug:[NSString stringWithFormat:@"> File Analyzer: (%ld) %@ [%d]", (unsigned long)[webfile length], file, _level]];
            
            if(webfile != NULL)
            {
                [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@",DownloadPath,[self pathFromURL:file]] withIntermediateDirectories:YES attributes:nil error:nil];
                
                //[self Debug:[NSString stringWithFormat:@"Replace %@ > %@", file,[NSString stringWithFormat:@"%@/%@/%@",[domain stringValue],[self pathFromURL:file],fileRoot]]];
//                webfile = [webfile stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"\"%@\"",file] withString:[NSString stringWithFormat:@"\"%@/%@/%@\"",[domain stringValue],[self pathFromURL:file],fileRoot]];
                [webfile writeToFile:[NSString stringWithFormat:@"%@/%@/%@",DownloadPath,[self pathFromURL:file],fileRoot] atomically:YES encoding:NSUTF8StringEncoding error:nil];
                
                NSArray *split;
                if(([[fileRoot pathExtension] isEqualToString:@"js"] || [[fileRoot pathExtension] isEqualToString:@"json"] || [[fileRoot pathExtension] isEqualToString:@"z"]) && _level <= [[level stringValue] intValue])
                {
                    if ([webfile rangeOfString:@","].location != NSNotFound)
                    {
                        split = [webfile componentsSeparatedByString: @","];
                    }
                    else if ([webfile rangeOfString:@";"].location != NSNotFound)
                    {
                        split = [webfile componentsSeparatedByString: @";"];
                    }
                    else if ([webfile rangeOfString:@":"].location != NSNotFound)
                    {
                        split = [webfile componentsSeparatedByString: @":"];
                    }
                    
                    //[self Debug:[NSString stringWithFormat:@"\tComponents (%ld)",(long)[split count]]];
                    
                    for(int u = 0; u < [split count]; u++)
                    {
                        //==================
                        NSArray* components;
                        if ([[split objectAtIndex:u] rangeOfString:@"\""].location != NSNotFound)
                        {
                            components = [[split objectAtIndex:u] componentsSeparatedByString: @"\""];
                        }
                        else if ([[split objectAtIndex:u] rangeOfString:@"("].location != NSNotFound)
                        {
                            components = [[split objectAtIndex:u] componentsSeparatedByString: @"("];
                        }
                        //==================
                        
                        for(int i = 0; i < [components count]; i++)
                        {
                            if ([[components objectAtIndex:i] rangeOfString:@";"].location != NSNotFound)
                            {
                                NSArray* _components = [[split objectAtIndex:u] componentsSeparatedByString: @";"];
                                for(int c = 0; c < [_components count]; c++)
                                {
                                    @try //Required
                                    {
                                        [self deepAnalyzer:file :[_components objectAtIndex:c] :[_components objectAtIndex:c-1] :[_components objectAtIndex:c-2] :_level];
                                    }
                                    @catch (NSException* ex)
                                    {
                                    }
                                }
                            }
                            else
                            {
                                @try //Required
                                {
                                    [self deepAnalyzer:file :[components objectAtIndex:i] :[components objectAtIndex:i-1] :[components objectAtIndex:i-2] :_level];
                                }
                                @catch (NSException* ex)
                                {
                                }
                            }
                        }
                    }
                }
            }
        }
        @catch (NSException* ex)
        {
            [self Debug:[NSString stringWithFormat:@"> ERROR: %@ (%@)",file, ex]];
        }
    }
}

-(void)deepAnalyzer:(NSString*)file :(NSString*)_url :(NSString*)arg1 :(NSString*)arg2 :(int)_level
{
    @autoreleasepool
    {
        @try //Just in case
        {
            if ([_url rangeOfString:@"."].location != NSNotFound && [_url rangeOfString:@"\n"].location == NSNotFound)
            {
                _url = [self bracketsCleanup:_url];
                
                //[self Debug:[NSString stringWithFormat:@"\tDeep Analyzer: %@ (%@,%@)",_url, arg1,arg2]];
                
                //==================
                BOOL hidden = FALSE;
                for(int i = 0; i < [jsExtentions count]; i++)
                {
                    if ([arg1 rangeOfString:[jsExtentions objectAtIndex:i]].location != NSNotFound || [arg2 rangeOfString:[jsExtentions objectAtIndex:i]].location != NSNotFound || [_url rangeOfString:[jsExtentions objectAtIndex:i]].location != NSNotFound)
                    {
                        hidden = TRUE;
                        break;
                    }
                }
                //==================
                
                if(hidden)
                {
                    if([binExtentions containsObject:[[self pathTagCleanup:_url] pathExtension]] || [imageExtentions containsObject:[[self pathTagCleanup:_url] pathExtension]]) //image files, no analisys needed
                    {
                        [self Debug:[NSString stringWithFormat:@"\tHidden Media: %@ [%d]", [self pathTagCleanup:_url], _level]];
                        
                        file = [self pathTagCleanup:_url];
                        BOOL DLmedia = TRUE; //download skin images but not galleries.
                        
                        for(int t = 0; t < [wixTags count]; t++)  //Replace [] with url
                        {
                            if ([_url rangeOfString:[wixTags objectAtIndex:t]].location != NSNotFound)
                            {
                                _url = [_url stringByReplacingOccurrencesOfString:[wixTags objectAtIndex:t] withString:[wixTagsURL objectAtIndex:t]];
                                break;
                            }
                        }
                        
                        _url = [self pathTagCleanup:_url];
                        
                        if ([_url rangeOfString:@"/"].location == NSNotFound)
                        {
                            _url = [NSString stringWithFormat:@"%@/%@",mediaURL,_url];
                        }
                        
                        if ([media state] != NSOnState && _level == 1)
                        {
                            DLmedia = FALSE;
                        }
                        
                        if(DLmedia && ![Bandwidth containsObject:_url])
                        {
                            //[self Debug:[NSString stringWithFormat:@"\tDownload Media: %@%@ [%d]", [self pathFromURL:_url],file, _level]];
                            
                            [Bandwidth addObject:_url];
                            
                            NSData* webBinary = [NSData dataWithContentsOfURL:[NSURL URLWithString:_url]];
                            
                            [[NSFileManager defaultManager] createDirectoryAtPath:[[NSString stringWithFormat:@"%@/%@",DownloadPath,[self pathFromURL:_url]] stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
                            
                            //wix has a dynamic image by size, using php to emulate the same
                            if ([php state] == NSOnState && [imageExtentions containsObject:[file pathExtension]])
                            {
                                NSString *imagePHP = [[NSString alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Resources/image.php",[[NSBundle mainBundle] bundlePath]] encoding:NSUTF8StringEncoding error:nil];
                                [imagePHP writeToFile:[NSString stringWithFormat:@"%@/%@%@",DownloadPath,[self pathFromURL:_url],file] atomically:YES encoding:NSUTF8StringEncoding error:nil];
                                
                                file = [NSString stringWithFormat:@"_%@",file];
                            }
                            
                            [webBinary writeToFile:[NSString stringWithFormat:@"%@/%@%@",DownloadPath,[self pathFromURL:_url],file] atomically:YES];
                        }
                    }
                    else if([txtExtentions containsObject:[_url pathExtension]])
                    {
                        [self Debug:[NSString stringWithFormat:@"\tHidden File: %@",_url]];
                        
                        [self fileAnalyzer:[NSString stringWithFormat:@"%@/%@",[file stringByDeletingLastPathComponent],_url] :[_url lastPathComponent] :_level+1];
                        
                        if ([_url rangeOfString:@"/javascript"].location != NSNotFound)
                        {
                            // Hidden java can also be found in javascript folder
                            [self fileAnalyzer:[NSString stringWithFormat:@"%@/javascript/%@",[file stringByDeletingLastPathComponent],_url] :[_url lastPathComponent] :_level+1];
                        }
                    }
                }
                else
                {
                    NSArray* parts = [[self pathTagCleanup:_url] componentsSeparatedByString: @"."];
                    
                    if([wixExtentions containsObject:[parts objectAtIndex:0]])
                    {
                        _url = [_url stringByReplacingOccurrencesOfString:@"." withString:@"/"];
                        
                        [self Debug:[NSString stringWithFormat:@"\tHidden JavaScript: %@.js",_url]];
                        
                        // Example:
                        // wysiwyg.viewer.skins.VideoSkin > http://static.parastorage.com/services/skins/services/skins/2.648.0/javascript/wysiwyg/viewer/skins/VideoSkin.js
                        // wysiwyg.viewer.components.WPhoto > http://static.parastorage.com/services/web/2.648.0/javascript/wysiwyg/viewer/components/WPhoto.js
                        
                        NSString* url =[file stringByDeletingLastPathComponent];
                        NSArray* urlstart = [url componentsSeparatedByString: @"/"];
                        NSString* ext = @".js";
                        
                        //other logical places (no worries duplicates will be ignored)
                        if ([[urlstart objectAtIndex:0] rangeOfString:@"core" options:NSCaseInsensitiveSearch].location != NSNotFound)
                        {
                            _url = [_url stringByReplacingOccurrencesOfString:@"mobile/" withString:@""]; // ..looks like "mobile" is being ignored in path
                            url =  coreURL;
                        }
                        else if ([[urlstart objectAtIndex:0] rangeOfString:@"components" options:NSCaseInsensitiveSearch].location != NSNotFound)
                        {
                            url = webURL;
                        }
                        else if ([_url rangeOfString:@"skins" options:NSCaseInsensitiveSearch].location != NSNotFound)
                        {
                            url = skinURL;
                        }
                        _url = [self pathTagCleanup:_url];
                        
                        [self fileAnalyzer:[NSString stringWithFormat:@"%@/javascript/%@%@",url ,_url,ext] :[NSString stringWithFormat:@"%@%@",[_url lastPathComponent],ext] :_level+1];
                    }
                }
            }
        }
        @catch (NSException* ex)
        {
            [self Debug:[NSString stringWithFormat:@"> ERROR: %@ (%@)",file, ex]];
        }
    }
}

-(NSString*)bracketsCleanup:(NSString*)_url
{
    //Take care of brackets
    if ([_url rangeOfString:@")"].location != NSNotFound)
    {
        NSArray* bktRight = [_url componentsSeparatedByString: @")"];
        _url = [bktRight objectAtIndex:0];
    }
    
    if ([_url rangeOfString:@"("].location != NSNotFound)
    {
        NSArray* bktLeft = [_url componentsSeparatedByString: @"("];
        _url = [bktLeft objectAtIndex:[bktLeft count]-1];
    }
    
    return _url;
}

-(NSString*)pathTagCleanup:(NSString*)path
{
    path = [path stringByReplacingOccurrencesOfString:@"]" withString:@""];
    path = [path stringByReplacingOccurrencesOfString:@"[" withString:@""];
    path = [path stringByReplacingOccurrencesOfString:@"{" withString:@""];
    path = [path stringByReplacingOccurrencesOfString:@"}" withString:@""];
    path = [path stringByReplacingOccurrencesOfString:@":" withString:@""];
    path = [path stringByReplacingOccurrencesOfString:@"," withString:@""];
    path = [path stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    path = [path stringByReplacingOccurrencesOfString:@"'" withString:@""];
    path = [path stringByReplacingOccurrencesOfString:@"http//" withString:@"http://"];
    return path;
}

-(NSString*)pathFromURL:(NSString*)url
{
    url = [url stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    NSArray* domainRoot = [url componentsSeparatedByString: @"/"]; //[url pathComponents];
    long end = [domainRoot count];
    
    if([binExtentions containsObject:[url pathExtension]] || [imageExtentions containsObject:[url pathExtension]] || [txtExtentions containsObject:[url pathExtension]] || [url rangeOfString:@"?"].location != NSNotFound)
    {
        end = [domainRoot count] - 1;
    }
    else if([[url pathExtension] isEqualToString:@""]) //if filename has no extention
    {
        end = [domainRoot count] -1;
    }
    
    NSString* buildURL = @"";
    for(int i = 1; i < end; i++)
    {
        buildURL = [NSString stringWithFormat:@"%@%@/",buildURL,[domainRoot objectAtIndex:i]];
    }
    return buildURL;
}

- (IBAction)tooltip_Click:(NSButton*)button
{
    ToolTipController* tipController = [[ToolTipController alloc] init];
    BOOL show = TRUE;
    
    if([[button title] isEqualToString:@"site"])
    {
        tipController.tip = @"Wix.com website,\nexample: http://bob51.wix.com/test";
    }
    else if([[button title] isEqualToString:@"domain"])
    {
        tipController.tip = @"Your own domain with full path,\nexample: www.coolbeans.com/joe";
    }
    else if([[button title] isEqualToString:@"email"])
    {
        tipController.tip = @"PHP Contact Form - email address";
    }
    else if([[button title] isEqualToString:@"level"])
    {
        tipController.tip = @"How deep '.js' files will be analyzed.\n\nWARNING: greater than 1 will retreive entire wix skin template.";
    }
    else if([[button title] isEqualToString:@"Download Media"])
    {
        if ([media state] == NSOnState)
        {
            tipController.tip = @"WARNING: all image files will be downloaded, this may be big";
        }
        else
        {
            show = FALSE;
        }
    }
    else if([[button title] isEqualToString:@"Download Editor"])
    {
        if ([editor state] == NSOnState)
        {
            tipController.tip = @"EXPERIMENTAL: Will download wix editor ajax files.";
        }
        else
        {
            show = FALSE;
        }
    }
    else if([[button title] isEqualToString:@"My Server has PHP"])
    {
        if ([php state] == NSOnState)
        {
            tipController.tip = @"EXPERIMENTAL:\nEmulate dynamic image size with php and enable contact form";
            [email setEnabled:YES];
        }
        else
        {
            [email setEnabled:NO];
            show = FALSE;
        }
    }
    else if([[button title] isEqualToString:@"Enable SEO"])
    {
        if ([seo state] == NSOnState)
        {
            tipController.tip = @"Search Engines like Google will be able to find your website";
        }
        else
        {
            show = FALSE;
        }
    }
    
    if(show)
    {
        NSPopover* help = [[NSPopover alloc] init];
        help.contentViewController = tipController;
        help.appearance = NSPopoverAppearanceHUD;
        [help setAnimates:YES];
        help.behavior = NSPopoverBehaviorTransient;
        
        if (!help.isShown)
        {
            [help showRelativeToRect:[button bounds] ofView:button preferredEdge:NSMaxYEdge];
        }
        else
        {
            [help close];
        }
    }
}

- (IBAction)download_Click:(id)sender;
{
    if([thread isExecuting])
    {
        [thread cancel];
        [self Debug:@"Downloading Stopped"];
        [download setTitle:@"Download"];
        
        [loading stopAnimation: self];
        [loading setHidden:TRUE];
        [progress stopAnimation: self];
    }
    else
    {
        //[site setStringValue:@"http://www.wix.com/website-template/view/html/853"];
        
        [loading setHidden:FALSE];
        [loading startAnimation: self];
        
        [progress setDoubleValue:0];
        [progress startAnimation: self];
        
        //Keeps track of redundant downloads, optimizes bandwidth
        Bandwidth = [[NSMutableSet alloc] init];
        
        
        if ([[site stringValue] rangeOfString:@"http://"].location == NSNotFound)
        {
            [site setStringValue:[NSString stringWithFormat:@"http://%@",[site stringValue]]];
        }
        
        if ([[domain stringValue] rangeOfString:@"http://"].location == NSNotFound)
        {
            [domain setStringValue:[NSString stringWithFormat:@"http://%@",[domain stringValue]]];
        }
        else if ([[domain stringValue] isEqualToString:@"http://"])
        {
            return;
        }
        
        if ([[domain stringValue] rangeOfString:@"127.0.0.1"].location != NSNotFound && [[[domain stringValue] stringByReplacingOccurrencesOfString:@"http://" withString:@""] rangeOfString:@":"].location == NSNotFound)
        {
            [domain setStringValue:[NSString stringWithFormat:@"%@:8000",[domain stringValue]]];
            [php setState:FALSE];
            [email setEnabled:NO];
        }
        
        thread = [[NSThread alloc] initWithTarget:self selector:@selector(startThread) object:nil];
        [thread start];
        
        [self Debug:@"Downloading Started"];
        [download setTitle:@"Stop"];
    }
}

- (void)Debug:(NSString*)d
{
    //NSLog(@"%@",d);
    printf("%s\n",[d UTF8String]);
    
    NSString* logpath = [NSString stringWithFormat:@"%@/pwned.log",DownloadPath];
    NSFileHandle* fh = [NSFileHandle fileHandleForWritingAtPath:logpath];
    
    if (!fh)
    {
        [[NSFileManager defaultManager] createFileAtPath:logpath contents:nil attributes:nil];
        fh = [NSFileHandle fileHandleForWritingAtPath:logpath];
    }
    if ( !fh ) return;
    
    @try
    {
        [fh seekToEndOfFile];
        [fh writeData:[[NSString stringWithFormat:@"%@\n",d] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    @catch (NSException * e)
    {
    }
    [fh closeFile];
}
-(void)downloadAndSaveLocal:(NSString*)url continue:(BOOL)whetherContinue more:(BOOL)more
{
    NSError *error=nil;
    DownloadPath = [NSString stringWithFormat:@"%@/Downloads/%@",NSHomeDirectory(),[url stringByReplacingOccurrencesOfString:@"http://" withString:@""]];
    
    NSString *indexHTML = [self downloadFile:url];

    //Prevent ":" in the directory name as port#
    DownloadPath = [DownloadPath stringByReplacingOccurrencesOfString:@":" withString:@"-"];
    [[NSFileManager defaultManager] createDirectoryAtPath:DownloadPath withIntermediateDirectories:YES attributes:nil error:&error];
    

    NSArray *filename = [url componentsSeparatedByString: @"/"];
    //Save original
    [indexHTML writeToFile:[NSString stringWithFormat:@"%@/%@",DownloadPath,[filename objectAtIndex:[filename count]-1]] atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if (!whetherContinue) {
        return;
    }
    
    
    
    {
        //Yes Son! split it
        NSArray *jsonHTTP = [indexHTML componentsSeparatedByString: @"\""];
        [progress setMaxValue:(int)[jsonHTTP count]];
        
        NSMutableArray *urlArray = [[NSMutableArray alloc]init];
        //==== Propriotery to wix.com ======
        for(int i = 0; i < [jsonHTTP count]; i++)  //Get static URLs dynamically
        {
            
            NSString *str  = [jsonHTTP objectAtIndex:i];
            
            if([str length] > 7 && str!=nil){
                
                if ([str rangeOfString:@"/Device/"].location != NSNotFound) {
//                    NSLog(str);
                    [urlArray addObject:str];
                }
            }
            
            
        }
        
        for(int i = 0; i < [urlArray count]; i++)
        {
            NSString *who = [urlArray objectAtIndex:i];
            NSString *postname = [filename objectAtIndex:[filename count]-1];
            if ([who rangeOfString:@"/Device/"].location != NSNotFound && ![who isEqualToString:@"/Device/Edit/Phone"] && ![who isEqualToString:@"/Device/History/Phone"] && [who rangeOfString:@"/Answers/"].location == NSNotFound && [who rangeOfString:@"ifixit"].location == NSNotFound && [who rangeOfString:@"/Device/Phone"].location == NSNotFound && [who rangeOfString:@"app-argument"].location == NSNotFound && ![who isEqualToString:[NSString stringWithFormat:@"%@%@",@"/Device/",postname]] && [who rangeOfString:@"/Edit/"].location == NSNotFound && [who rangeOfString:@"/History/"].location == NSNotFound && [who rangeOfString:@"/new/"].location == NSNotFound) //pick only url and avoid comments
            {
                if([[NSThread currentThread] isCancelled])
                    [NSThread exit];
                
                //===================================
                NSString* fileDownload = [NSString stringWithFormat:@"%@%@",@"http://www.ifixit.com",[urlArray objectAtIndex:i]];
                NSArray* domainRoot = [[fileDownload stringByReplacingOccurrencesOfString:@"http://" withString:@""] componentsSeparatedByString: @"/"];
                
                NSString* dirRoot = [self pathFromURL:fileDownload];
                
                [self downloadAndSaveLocalMore:fileDownload];
            }
            
        }

    }
}
-(void)downloadAndSaveLocalMore:(NSString*)url
{
    NSError *error=nil;
    DownloadPath = [NSString stringWithFormat:@"%@/Downloads/%@",NSHomeDirectory(),[url stringByReplacingOccurrencesOfString:@"http://" withString:@""]];
    
    NSString *indexHTML = [self downloadFile:url];
    
    //Prevent ":" in the directory name as port#
    DownloadPath = [DownloadPath stringByReplacingOccurrencesOfString:@":" withString:@"-"];
    [[NSFileManager defaultManager] createDirectoryAtPath:DownloadPath withIntermediateDirectories:YES attributes:nil error:&error];
    
    
    NSArray *filename = [url componentsSeparatedByString: @"/"];
    //Save original
    [indexHTML writeToFile:[NSString stringWithFormat:@"%@/%@",DownloadPath,[filename objectAtIndex:[filename count]-1]] atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
        //Yes Son! split it
        NSArray *jsonHTTP = [indexHTML componentsSeparatedByString: @"\""];
        [progress setMaxValue:(int)[jsonHTTP count]];
        
        NSMutableArray *urlArray = [[NSMutableArray alloc]init];
        //==== Propriotery to wix.com ======
        for(int i = 0; i < [jsonHTTP count]; i++)  //Get static URLs dynamically
        {
            
            NSString *str  = [jsonHTTP objectAtIndex:i];
            
            if([str length] > 7){
                
                if ([str rangeOfString:@"/Guide/"].location != NSNotFound) {
//                                        NSLog(str);
                    [urlArray addObject:str];
                }
            }
            
            
        }
        
        for(int i = 0; i < [urlArray count]; i++)
        {
            NSString *who = [urlArray objectAtIndex:i];
            NSString *postname = [filename objectAtIndex:[filename count]-1];
            if ([who rangeOfString:@"/Guide/"].location != NSNotFound && ![who isEqualToString:@"/Guide/login/register"] && ![who isEqualToString:@"/Guide/login"] && ![who isEqualToString:@"/Guide/Search"] && [who rangeOfString:@"/new/"].location == NSNotFound && [who rangeOfString:@"/Device/"].location == NSNotFound && ![who isEqualToString:[NSString stringWithFormat:@"%@%@",@"/Device/",postname]] && [who rangeOfString:@"cloudfront"].location == NSNotFound ) //pick only url and avoid comments
            {
                if([[NSThread currentThread] isCancelled])
                    [NSThread exit];
                
                //===================================
                NSString* url = [NSString stringWithFormat:@"%@%@",@"http://www.ifixit.com",[urlArray objectAtIndex:i]];
                
                NSError *error=nil;
                DownloadPath = [NSString stringWithFormat:@"%@/Downloads/%@",NSHomeDirectory(),@"www.ifixit.com/HTML"];
                
                NSString *indexHTML = [self downloadFile:url];
                
                //Prevent ":" in the directory name as port#
                DownloadPath = [DownloadPath stringByReplacingOccurrencesOfString:@":" withString:@"-"];
                [[NSFileManager defaultManager] createDirectoryAtPath:DownloadPath withIntermediateDirectories:YES attributes:nil error:&error];
                
                
                NSArray *filename = [url componentsSeparatedByString: @"/"];
                //Save original
                [indexHTML writeToFile:[NSString stringWithFormat:@"%@/%@",DownloadPath,[NSString stringWithFormat:@"%@.html",[filename objectAtIndex:[filename count]-1]]] atomically:YES encoding:NSUTF8StringEncoding error:&error];
                

            }
            
        }
    
}
-(void)moreDeepDownload:(NSString*)indexHTML
{
    
}
@end
