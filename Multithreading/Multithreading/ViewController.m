//
//  ViewController.m
//  Multithreading
//
//  Created by MAC on 2018/11/22.
//  Copyright © 2018年 MAC. All rights reserved.
//

#import "ViewController.h"
#import <pthread.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
     ios多线程开发的常用四种方式和基本使用
     1.pthread
     2.NSThread
     3.NSOperation\NSOperationQueue
     4.GCD
     
     一 、pthread
     C语言通用的多线程API，跨平台，程序员手动管理线程生命周期，使用难度大
     */
    //创建线程
   /* NSLog(@"开始执行");
    int pthread_create(pthread_t * __restrict ,const pthread_attr_t * __restrict ,void *(*)(void *),void * __restrict);
    //使用
    pthread_t pthread;
    pthread_create(&pthread, NULL, function, NULL);
    NSLog(@"执行结束");*/
    
//    [self createThread];
//    [self createOperation];
    [self createGCD];
}

void * function(void * param) {
    for (int i = 0; i < 5; i ++) {
        NSLog(@"i : %d-- 线程： %@",i,[NSThread currentThread]);
    }
    return NULL;
}
/*运行结果
 2018-11-22 11:49:57.045504+0800 Multithreading[20231:4407861] 开始执行
 2018-11-22 11:49:57.045716+0800 Multithreading[20231:4407861] 执行结束
 2018-11-22 11:49:57.045828+0800 Multithreading[20231:4409725] i : 0-- 线程： <NSThread: 0x6080002724c0>{number = 3, name = (null)}
 2018-11-22 11:49:57.046230+0800 Multithreading[20231:4409725] i : 1-- 线程： <NSThread: 0x6080002724c0>{number = 3, name = (null)}
 2018-11-22 11:49:57.047038+0800 Multithreading[20231:4409725] i : 2-- 线程： <NSThread: 0x6080002724c0>{number = 3, name = (null)}
 2018-11-22 11:49:57.047152+0800 Multithreading[20231:4409725] i : 3-- 线程： <NSThread: 0x6080002724c0>{number = 3, name = (null)}
 2018-11-22 11:49:57.047439+0800 Multithreading[20231:4409725] i : 4-- 线程： <NSThread: 0x6080002724c0>{number = 3, name = (null)}

*/

/*
 二、 NSThread
 */
- (void)createThread {
    //创建NSThread 有三种方法
    // 方法 1 需要手动开启
    NSThread * thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadMoth) object:nil];
    [thread start];
    //方法 2
    [NSThread detachNewThreadSelector:@selector(threadMoth) toTarget:self withObject:nil];
    //方法 3
    [self performSelectorInBackground:@selector(threadMoth) withObject:nil];
    
    //常用的相关方法
   /* [NSThread mainThread];// 获得主线程
    [NSThread isMainThread]; //是否为主线程
    NSLog(@"shuchu--%@--%d",[NSThread mainThread],[NSThread isMainThread]);
    NSLog(@"休眠前");
    [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:4.0]];//阻塞线程 以当前时间为准阻塞4秒
    NSLog(@"休眠1");
    [NSThread sleepForTimeInterval:2];//阻塞线程 2 秒
    NSLog(@"休眠后");
    [NSThread exit];// 强制退出线程*/
    /*
     方法2、一调用就会立即创建一个线程来做事情；
     方法1、需要手动调用 start 启动线程时才会真正去创建线程。
     方法3、是利用NSObject的方法  performSelectorInBackground:withObject: 来创建一个线程：在后台运行某一个方法
     与 NSThread 的 detachNewThreadSelector:toTarget:withObject: 是一样的。
     
     运行结果
     2018-11-22 16:17:36.959316+0800 Multithreading[20834:4901061] <NSThread: 0x60c00007b800>{number = 4, name = (null)}
     2018-11-22 16:17:36.959318+0800 Multithreading[20834:4901060] <NSThread: 0x60c00007b8c0>{number = 3, name = (null)}
     2018-11-22 16:17:36.960902+0800 Multithreading[20834:4901062] <NSThread: 0x60c00007bc40>{number = 5, name = (null)}
     */
}

- (void)createOperation {
    /*
     NSOperation、NSOperationQueue 是苹果提供给我们的一套多线程解决方案。实际上 NSOperation、NSOperationQueue 是基于 GCD 更高一层的封装，完全面向对象。但是比 GCD 更简单易用、代码可读性也更高。
     
     NSOperation 是个抽象类，不能用来封装操作。我们只有使用它的子类来封装操作。我们有两种方式来封装操作。
     子类 NSInvocationOperation
     子类 NSBlockOperation
     
     */
//   子类 NSInvocationOperation
//    1、创建 NSInvocationOperation 对象
    NSInvocationOperation * operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(threadMoth) object:nil];
//    2.调用 start 方法开始执行操作
    [operation start];
    /* 运行结果 2018-11-22 16:17:36.959446+0800 Multithreading[20834:4899673] <NSThread: 0x600000075840>{number = 1, name = main}
       通过运行结果 可以看到 在没有加入到NSOperationQueue中，而是单独使用的时候，NSInvocationOperation 并没有开启新的线程，还是在主线程中执行的
     */
    // 子类NSBlockOperation  1、创建
    NSBlockOperation * block = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"block-%@",[NSThread currentThread]);
    }];
    // 2.添加额外的操作
    [block addExecutionBlock:^{
        NSLog(@"block-%@",[NSThread currentThread]);// 打印当前线程
    }];
    //3.调用 start 方法开始执行操作
    [block start];
    /*运行结果：2018-11-22 16:41:36.057252+0800 Multithreading[20893:4948069] <NSThread: 0x600000074a00>{number = 1, name = main}
     和NSInvocationOperation 使用一样。因为代码是在主线程中调用的，所以打印结果为主线程。如果在其他线程中执行操作，则打印结果为其他线程。
     通过 addExecutionBlock: 就可以为 NSBlockOperation 添加额外的操作。
     */
    /*//NSOperationQueue   NSOperation 需要配合 NSOperationQueue 来实现多线程
    需要将创建好的操作加入到队列中去。总共有两种方法：
    1、- (void)addOperation:(NSOperation *)op;
    需要先创建操作，再将创建好的操作加入到创建好的队列中去。
     */
    //创建队列
    NSOperationQueue * queue = [[NSOperationQueue alloc] init];
    //添加操作
    NSInvocationOperation * operation1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(threadMoth) object:nil];
    NSInvocationOperation * operation2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(threadMoth) object:nil];
    NSBlockOperation * block1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"block1-%@",[NSThread currentThread]);// 打印当前线程
    }];
    [block1 addExecutionBlock:^{
        NSLog(@"block2-%@",[NSThread currentThread]);// 打印当前线程
    }];
    //3 添加队列
    [queue addOperation:operation1];
    [queue addOperation:operation2];
    [queue addOperation:block1];
    /*运行结果
     2018-11-22 17:27:58.671071+0800 Multithreading[23002:5205701] <NSThread: 0x600000262ac0>{number = 3, name = (null)}
     2018-11-22 17:27:58.671073+0800 Multithreading[23002:5205666] queue1-<NSThread: 0x60c000265a80>{number = 5, name = (null)}
     2018-11-22 17:27:58.671071+0800 Multithreading[23002:5205664] block1-<NSThread: 0x608000260400>{number = 6, name = (null)}
     2018-11-22 17:27:58.671115+0800 Multithreading[23002:5205663] <NSThread: 0x608000260340>{number = 4, name = (null)}
     使用 NSOperation 子类创建操作，并使用 addOperation: 将操作加入到操作队列后能够开启新线程，进行并发执行。
     2、- (void)addOperationWithBlock:(void (^)(void))block;
     无需创建操作，在 block 中添加操作，直接将包含操作的 block 加入到队列中。
     */
    NSOperationQueue * queue1 = [[NSOperationQueue alloc] init];
    [queue1 addOperationWithBlock:^{
        NSLog(@"queue1-%@",[NSThread currentThread]);// 打印当前线程
    }];
    [queue1 addOperationWithBlock:^{
        NSLog(@"queue1-%@",[NSThread currentThread]);// 打印当前线程
    }];
    [queue1 addOperationWithBlock:^{
        NSLog(@"queue1-%@",[NSThread currentThread]);// 打印当前线程
    }];
    [queue1 addOperationWithBlock:^{
        NSLog(@"queue1-%@",[NSThread currentThread]);// 打印当前线程
    }];
    
    /*运行结果
     2018-11-22 17:27:58.671156+0800 Multithreading[23002:5205665] queue1-<NSThread: 0x6000002613c0>{number = 7, name = (null)}
     2018-11-22 17:27:58.671322+0800 Multithreading[23002:5205664] block2-<NSThread: 0x608000260400>{number = 6, name = (null)}
     2018-11-22 17:27:58.671331+0800 Multithreading[23002:5205666] queue1-<NSThread: 0x60c000265a80>{number = 5, name = (null)}
     2018-11-22 17:27:58.671367+0800 Multithreading[23002:5205701] queue1-<NSThread: 0x600000262ac0>{number = 3, name = (null)}
     使用 addOperationWithBlock: 将操作加入到操作队列后能够开启新线程，进行并发执行。
     */
}

- (void)createGCD {
    /*
     GCD会自动利用更多的CPU内核，会自动管理线程的生命周期，不需要写管理线程的代码。定制任务 将任务添加到队列中 GCD会自动将队列中的任务取出，放到线程中去执行，任务的取出遵循FIFO原则。
     
     1. Main queue：
     　　运行在主线程,由dispatch_get_main_queue获得.和ui相关的就要使用MainQueue，在主线程中更新ui.
     2. Serial quque(private dispatch queue)
     　　每次运行一个任务,可以添加多个,执行次序FIFO.
     3. Concurrent queue(globaldispatch queue):
     可以同时运行多个任务,每个任务的启动时间是按照加入queue的顺序,结束的顺序依赖各自的任务.使用dispatch_get_global_queue获得.
     所以我们可以大致了解使用GCD的框架:
     同步 在当前线程中执行
     dispatch_sync(dispatch_queue_t queue, ^(void)block)
     异步 可以在新的线程中执行,有开新线程的能力（不是一定会开新线程，比如放在主队列中）
     dispatch_async(dispatch_queue_t queue, ^(void)block)
     常用地方
     */
    
    //延迟执行
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"延时2秒执行");
    });
    //全局异步并发队列
    /**
     参数 identifier 优先级
     参数 flags      保留参数 默认传0
     */
    dispatch_queue_t queuet = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queuet, ^{
        NSLog(@"queuet --- 1");
    });
    dispatch_async(queuet, ^{
        NSLog(@"queuet --- 2");
    });
    dispatch_async(queuet, ^{
        NSLog(@"queuet --- 3");
    });
    
    //自定义并发队列
    dispatch_queue_t queuet1 = dispatch_queue_create("www.baidu.com", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queuet1, ^{
        NSLog(@"queuet1 --- 1");
    });
    dispatch_async(queuet1, ^{
        NSLog(@"queuet1 --- 2");
    });
    dispatch_async(queuet1, ^{
        NSLog(@"queuet1 --- 3");
    });
    
    dispatch_queue_t queuet2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queuet2, ^{
        NSLog(@"queuet2 --- 1");
    });
    dispatch_barrier_async(queuet2, ^{
        NSLog(@"queuet2 --- 2");
    });
  
    //group
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"group1");
    });
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"group2");
    });
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"group3");
    });
    

    //创建单例
    /*static dispatch_once_t onceToken;
    static ViewController * viewController;
    dispatch_once(&onceToken, ^{
        viewController = [[ViewController alloc] init];
    });
    return viewController;*/
    
    
    /*
     多线程的安全隐患
     资源共享：
     一块资源可能会被多个线程共享，比如多个线程访问同一个对象、对一个变量、同一个文件
     
     解决方法：
     互斥锁
     @synchronized(锁对象){ //需要锁定的代码 }
     或者 加NSLock锁
     
     原子和非原子属性
     atomic 默认 原子属性 为setter方法加锁
     线程安全，需要消耗大量的资源
     nonatomic 非原子属性 不会为setter方法加锁
     非线程安全，适合内存小的移动设备
     
     注意：
     所有属性都声明为nonatomic
     尽量避免多线程抢夺同一块资源
     尽量加加锁、资源抢夺的业务逻辑交给服务器处理，减小移动客户端压力
     
     */
    
}

- (void)threadMoth {
    NSLog(@"%@",[NSThread currentThread]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
