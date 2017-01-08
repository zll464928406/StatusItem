//
//  NSString+Extension.m
//  XeShare
//
//  Created by Hillman Li on 10/23/12.
//
//

#import "NSString+Extension.h"
#import "NS(Attributed)String+Geometrics.h"

@implementation NSString (Extension)

+ (id)stringWithFormat:(NSString *)format array:(NSArray*) arguments
{
    NSRange range = NSMakeRange(0, [arguments count]);
    NSMutableData* data = [NSMutableData dataWithLength: sizeof(id) * [arguments count]];
    [arguments getObjects: (__unsafe_unretained id *)data.mutableBytes range:range];
    NSString * result = [[NSString alloc] initWithFormat: format  arguments: data.mutableBytes];
    return [result autorelease];
}

- (NSString *)trim
{
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [self stringByTrimmingCharactersInSet: whitespace];
}

- (BOOL)isNotEmpty
{
	return (self.length>0?YES:NO);
}

- (NSString *)briefStringWithLength:(int)length
{
    NSUInteger totalLen = [self length];
    if(totalLen > length)
    {
        NSString *subString1 = [self substringToIndex:length/2];
        NSUInteger fromIndex = [self length] - (length/2-3)-1;
        NSString *subString2 = [self substringFromIndex:fromIndex];
        return [NSString stringWithFormat:@"%@...%@",subString1,subString2];
    }
    return self;
}

+ (NSString *)safeStringForArrayItem:(NSString *)unSafeString
{
    if(unSafeString == nil)
        return @"";
    return unSafeString;
}

- (CGFloat)caculateHeightWithFontType:(NSFont *)font rowWidth:(CGFloat)rowWidth
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    NSAttributedString *text = [[[NSAttributedString alloc] initWithString:self attributes: attributes] autorelease];
    NSRect textRext = [text boundingRectWithSize:NSMakeSize(rowWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading];
    
    return textRext.size.height;
}

- (CGFloat)caculateHeightWithFontType:(NSFont *) font
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    NSAttributedString *text = [[[NSAttributedString alloc] initWithString:self attributes: attributes] autorelease];
    NSRect textRext = [text boundingRectWithSize:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading];
    
    return textRext.size.height;
}

- (NSSize)caculateSizeWithFontType:(NSFont *)font rowWidth:(CGFloat)rowWidth
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    NSAttributedString *text = [[[NSAttributedString alloc] initWithString:self attributes: attributes] autorelease];
    NSRect textRext = [text boundingRectWithSize:NSMakeSize(rowWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading];
    
    return textRext.size;
}

- (NSSize)caculateSizeWithFontType:(NSFont *) font
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    NSAttributedString *text = [[[NSAttributedString alloc] initWithString:self attributes: attributes] autorelease];
    NSRect textRext = [text boundingRectWithSize:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading];
    
    return textRext.size;
}

- (NSString*)filterNumbers
{
    NSMutableString *strippedString = [NSMutableString
                                       stringWithCapacity:self.length];
    
    NSScanner *scanner = [NSScanner scannerWithString:self];
    NSCharacterSet *numbers = [NSCharacterSet
                               characterSetWithCharactersInString:@"0123456789"];
    
    while ([scanner isAtEnd] == NO) {
        NSString *buffer;
        if ([scanner scanCharactersFromSet:numbers intoString:&buffer]) {
            [strippedString appendString:buffer];
            
        } else {
            [scanner setScanLocation:([scanner scanLocation] + 1)];
        }
    }
    return strippedString;
}

- (BOOL)isSamePath:(NSString *) path;
{
    if(!path)
        return FALSE;
    
    if([path hasSuffix:@"/"]) {
        path = [path substringToIndex:path.length-1];
    }
    
    if([self hasSuffix:@"/"])
        return [[self substringToIndex:self.length-1] isEqualToString:path];
    else
        return [self isEqualToString:path];
}

- (NSString*)urlEncode
{
    if ([self respondsToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
        
        NSString *charactersToEscape = @"!*'();:@&=+$,/?%#[]\" ";
        NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
        
        NSString *encodeBackUrl = [self stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
        
        return encodeBackUrl;
    }
    else {
        
        NSString * encodeBackUrl =
        (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                            NULL,
                                                            (CFStringRef)self,
                                                            NULL,
                                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]\" ",
                                                            kCFStringEncodingUTF8 );
        
        return [encodeBackUrl autorelease];
    }
}



- (BOOL)containsString:(NSString *)string
               options:(NSStringCompareOptions)options {
    NSRange rng = [self rangeOfString:string options:options];
    return rng.location != NSNotFound;
}

- (BOOL)containsString:(NSString *)string {
    return [self containsString:string options:0];
}
@end

