//
//  ViewController.m
//  NSOperation
//
//  Created by soliloquy on 2017/8/10.
//  Copyright © 2017年 soliloquy. All rights reserved.
//

#import "ViewController.h"
#import "PTLCustomOperation.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    /*
     NSOperation实现多线程的使用步骤分为三步：
     
     创建任务：先将需要执行的操作封装到一个NSOperation对象中。
     创建队列：创建NSOperationQueue对象。
     将任务加入到队列中：然后将NSOperation对象添加到NSOperationQueue中。
     之后呢，系统就会自动将NSOperationQueue中的NSOperation取出来，在新线程中执行操作。
     
     NSOperation是个抽象类，并不能封装任务。我们只有使用它的子类来封装任务。我们有三种方式来封装任务。
     使用子类NSInvocationOperation
     使用子类NSBlockOperation
     定义继承自NSOperation的子类，通过实现内部相应的方法来封装任务。

     // 添加依赖 依赖关系需添加到addOperation代码之前, 否则无效
     */
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self operationDemo4];
}

//添加NSOperation的依赖对象
- (void)operationDemo4 {
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    // 创建操作
    // NSInvocationOperation形式
    NSInvocationOperation *invacation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(run:) object:@"NSInvocationOperation"];
    // block形式
    NSBlockOperation *block = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"block: --- %@", [NSThread currentThread]);
    }];
    // 自定义形式
    PTLCustomOperation *custom = [[PTLCustomOperation alloc]init];
    
    // 添加依赖 依赖关系需添加到addOperation代码之前, 否则无效
    [block addDependency:invacation];
    [custom addDependency:block];
    
    // 添加操作到队列中：addOperation:
    [queue addOperation:invacation];    //== [op1 start]
    [queue addOperation:block];         //== [op1 start]
    [queue addOperation:custom];
}

- (void)operationDemo3 {
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; ++i) {
            NSLog(@"-----%@", [NSThread currentThread]);
        }
    }];
}

// 使用NSOperationQueue
- (void)operationDemo2 {
    
    NSLog(@"开始--------------");
    /*
     ```操作如果没有加入到队列中 不会开启子线程 会在主队列运行任务
     ```只有加入到NSOperationQueue(addOperation)后 任务才会开启子线程
     */
    // 创建队列 队列是并行队列 不阻塞当前线程
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    // 创建操作
    // NSInvocationOperation形式
    NSInvocationOperation *invacation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(run:) object:@"NSInvocationOperation"];
    // block形式
    NSBlockOperation *block = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"block: --- %@", [NSThread currentThread]);
    }];
    // 自定义形式
    PTLCustomOperation *custom = [[PTLCustomOperation alloc]init];
    
//    添加操作到队列中：addOperation:   
    [queue addOperation:invacation];    //== [op1 start]
    [queue addOperation:block];         //== [op1 start]
    [queue addOperation:custom];

    
    /*
     wait: 
     ```YES---阻塞当前线程,  需等待队列任务执行完毕,才会执行后面的内容
     ```NO--- 不阻塞当前线程  不用等待队列任务执行完毕就可以执行后面的操作
     */
//    [queue addOperations:@[invacation, block, custom] waitUntilFinished:NO];
    
    NSLog(@"结束");
}


/**
    NSBlockOperation还提供了一个方法addExecutionBlock:，通过addExecutionBlock:就可以为NSBlockOperation添加额外的操作，这些额外的操作就会在其他线程并发执行。
 // 当主线程的任务完成后, 额外的任务也有可能到主线程执行
 2017-08-10 15:57:54.682 NSOperation[3704:1469121] 1------<NSThread: 0x61800007b3c0>{number = 1, name = main}
 2017-08-10 15:57:54.683 NSOperation[3704:1469121] 4------<NSThread: 0x61800007b3c0>{number = 1, name = main}
 2017-08-10 15:57:54.683 NSOperation[3704:1469802] 2------<NSThread: 0x600000262a00>{number = 5, name = (null)}
 2017-08-10 15:57:54.684 NSOperation[3704:1475479] 3------<NSThread: 0x61000007c100>{number = 9, name = (null)}

 */
- (void)operationDemo1 {
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        // 在主线程
        NSLog(@"1------%@", [NSThread currentThread]);
    }];
    
    // 添加额外的任务(在子线程执行)
    [op addExecutionBlock:^{
        NSLog(@"2------%@", [NSThread currentThread]);
    }];
    [op addExecutionBlock:^{
        NSLog(@"3------%@", [NSThread currentThread]);
    }];
    [op addExecutionBlock:^{
        NSLog(@"4------%@", [NSThread currentThread]);
    }];
    
    [op start];
}

- (void)run:(id)param {
    NSLog(@"invacation:  --- %@", [NSThread currentThread]);
}

@end
