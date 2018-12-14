//
//  GLUtil.h
//  JDGLESAVO
//
//  Created by wudong on 2018/12/14.
//  Copyright © 2018 jundong. All rights reserved.
//

#ifndef GLUtil_h
#define GLUtil_h


#ifdef __cplusplus
extern "C" {
#endif
    
#define GLES_PLATFORM_IOS           1
#define GLES_PLATFORM_ANDROID       2
    

#if defined(__APPLE__) && !defined(ANDROID)
#include <TargetConditionals.h>
#if TARGET_OS_IPHONE
#undef  GLES_TARGET_PLATFORM
#define GLES_TARGET_PLATFORM         GLES_PLATFORM_IOS
#endif
#endif


#if defined(ANDROID)
#undef  GLES_TARGET_PLATFORM
#define GLES_TARGET_PLATFORM         GLES_PLATFORM_ANDROID
#endif
    
#if GLES_TARGET_PLATFORM == GLES_PLATFORM_IOS
#include <OpenGLES/ES3/gl.h>
#include <OpenGLES/ES3/glext.h>
#include <stdio.h>
#define GLlog(format,...)       printf(format,__VA_ARGS__)
#endif
    
    
    
    long getFileContext(char *buffer, long len, const char *filePath);
    
    GLuint createGLProgram(const char *vertext, const char *frag);
    
    GLuint createGLProgramFromFile(const char *vertextPath, const char *fragPath);
    
    GLuint createVBO(GLenum target, int usage, int datSize, void *data);
    
    GLuint createTexture2D(GLenum format, int width, int height, void *data);
    
    GLuint createVAO(void(*setting)());
    
#ifdef __cplusplus
}
#endif
#endif /* GLUtil_h */




