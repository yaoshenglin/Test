//
//  Ping.m
//  test
//
//  Created by Yin on 15-5-25.
//  Copyright (c) 2015年 Yinhaibo. All rights reserved.
//

#import "Ping.h"
#include <netdb.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <sys/time.h>
#include <netinet/ip.h>
#include <netinet/ip_icmp.h>

#define PACKET_SIZE 4096
#define MAX_WAIT_TIME   5
#define MAX_NO_PACKETS  50

char *addr[100];
int sockfd,datalen = 56;
struct sockaddr_in dest_addr;
pid_t pid;
int nsend = 0, nreceived = 0;
char sendpacket[PACKET_SIZE];
char recvpacket[PACKET_SIZE];
double temp_rtt[MAX_NO_PACKETS];
double all_time = 0;
struct sockaddr_in from;
struct timeval tvrecv;

typedef void (^myBlock)(int sock,NSData *data);

@interface Ping ()
{
    myBlock iBlock;
}

@end

@implementation Ping

+ (Ping *)getInstance
{
    static dispatch_once_t once;
    static Ping *sharedInstance;
    dispatch_once(&once, ^ {
        sharedInstance = [[Ping alloc] init];
    });
    return sharedInstance;
}

+ (void)PingDomain:(NSString *)domain
{
    if (!domain || ![domain isKindOfClass:[NSString class]]) {
        return;
    }
    
    ping((char *)domain.UTF8String, 5, 5);
    closeSocket();
}

+ (void)PingDomain:(NSString *)domain count:(int)count
{
    if (!domain || ![domain isKindOfClass:[NSString class]]) {
        return;
    }
    
    nsend = MAX_NO_PACKETS - count;
    ping((char *)domain.UTF8String, 5, 5);
    closeSocket();
}

- (instancetype)init
{
    if ((self = [super init])) {
        iBlock = ^(int sock,NSData *data) {};
    }
    
    return self;
}

- (void)PingDomain:(NSString *)domain
{
    if (!domain || ![domain isKindOfClass:[NSString class]]) {
        return;
    }
    
    ping((char *)domain.UTF8String, 5, 5);
    
    __block id delegate = _delegate;
    iBlock = ^(int sock,NSData *data) {
        if ([delegate respondsToSelector:@selector(receiveData:)]) {
            [delegate receiveData:data];
        }
    };
}

- (void)PingDomain:(NSString *)domain completion:(void (^)(NSData *data))handler
{
    [self PingDomain:domain];
    iBlock = ^(int sock,NSData *data) {
        handler(data);
    };
}

- (void)receiveData:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"str = %@",str);
}

- (void)close
{
    closeSocket();
}

void closeSocket()
{
    int result = close(sockfd);
    if (result == 0) {
        //连接已经关闭
    }
}

//ping
void ping(char *address, long sendOut,long revOut)
{
    struct hostent *host;
    struct protoent *protocol;
    int size = 50 * 1024;
    addr[0] = address;
    
    if((protocol = getprotobyname("icmp")) == NULL)
    {
        perror("getprotobyname");
        return;
    }
    
    //生成使用ICMP的原始套接字
    if((sockfd = socket(AF_INET,SOCK_DGRAM,IPPROTO_ICMP)) < 0)
    {
        perror("socket error");
        return;
    }
    
    
    /*扩大套接字的接收缓存区导50K，这样做是为了减小接收缓存区溢出的
     可能性，若无意中ping一个广播地址或多播地址，将会引来大量的应答*/
    setsockopt(sockfd,SOL_SOCKET,SO_RCVBUF,&size,sizeof(size));
    bzero(&dest_addr,sizeof(dest_addr));    //初始化
    dest_addr.sin_family = AF_INET;     //套接字域是AF_INET(网络套接字)
    
    struct timeval timeoutSend = {sendOut,0};//5s
    setsockopt(sockfd,SOL_SOCKET,SO_SNDTIMEO,(const char*)&timeoutSend,sizeof(timeoutSend));
    struct timeval timeoutRev = {revOut,0};//15s
    setsockopt(sockfd,SOL_SOCKET,SO_RCVTIMEO,(const char*)&timeoutRev,sizeof(timeoutRev));
    
    //判断主机名是否是IP地址
    if(inet_addr(address) == INADDR_NONE)
    {
        if((host = gethostbyname(address)) == NULL) //是主机名
        {
            perror("gethostbyname error");
            closeSocket();
            return;
        }
        memcpy((char *)&dest_addr.sin_addr,host->h_addr,host->h_length);
    }
    else{
        //是IP 地址
        dest_addr.sin_addr.s_addr = inet_addr(address);
    }
    //获取进程识别码
    pid = getpid();
    printf("PING %s(%s):%d bytes of data.\n",address,
           inet_ntoa(dest_addr.sin_addr),datalen);
    
    //当按下ctrl+c时发出中断信号，并开始执行统计函数
    //signal(SIGINT,statistics);
    while(nsend < MAX_NO_PACKETS) {
        sleep(1);       //每隔一秒发送一个ICMP报文
        send_packet();      //发送ICMP报文
        recv_packet();      //接收ICMP报文
    }
    
    closeSocket();
}

/****发送三个ICMP报文****/
void send_packet()
{
    int packetsize;
    if(nsend < MAX_NO_PACKETS)
    {
        nsend++;
        packetsize = pack(nsend);   //设置ICMP报头
        //发送数据报
        if(sendto(sockfd,sendpacket,packetsize,0,
                  (struct sockaddr *)&dest_addr,sizeof(dest_addr)) < 0)
        {
            perror("sendto error");
        }
    }
    
}

/****接受所有ICMP报文****/
void recv_packet()
{
    int fromlen;
    ssize_t n;
    extern int error;
    fromlen = sizeof(from);
    if(nreceived < nsend)
    {
        //接收数据报
        if((n = recvfrom(sockfd,recvpacket,sizeof(recvpacket),0,
                         (struct sockaddr *)&from,(socklen_t *)&fromlen)) < 0)
        {
            perror("recvfrom error");
        }
        
        gettimeofday(&tvrecv,NULL);     //记录接收时间
        unpack(recvpacket,n);       //剥去ICMP报头
        nreceived++;
    }
}

/*设置ICMP报头*/
int pack(int pack_no)
{
    int packsize;
    struct icmp *icmp;
    struct timeval *tval;
    icmp = (struct icmp*)sendpacket;
    icmp->icmp_type = ICMP_ECHO;    //ICMP_ECHO类型的类型号为0
    icmp->icmp_code = 0;
    icmp->icmp_cksum = 0;
    icmp->icmp_seq = pack_no;   //发送的数据报编号
    icmp->icmp_id = pid;
    
    packsize = 8 + datalen;     //数据报大小为64字节
    tval = (struct timeval *)icmp->icmp_data;
    gettimeofday(tval,NULL);        //记录发送时间
    //校验算法
    icmp->icmp_cksum =  cal_chksum((unsigned short *)icmp,packsize);
    return packsize;
}

/******剥去ICMP报头******/
int unpack(char *buf,long len)
{
    int iphdrlen;       //ip头长度
    struct ip *ip;
    struct icmp *icmp;
    struct timeval *tvsend;
    double rtt;
    
    ip = (struct ip *)buf;
    iphdrlen = ip->ip_hl << 2;  //求IP报文头长度，即IP报头长度乘4
    icmp = (struct icmp *)(buf + iphdrlen); //越过IP头，指向ICMP报头
    len -= iphdrlen;    //ICMP报头及数据报的总长度
    if(len < 8)     //小于ICMP报头的长度则不合理
    {
        printf("ICMP packet\'s length is less than 8\n");
        return -1;
    }
    //确保所接收的是所发的ICMP的回应
    if((icmp->icmp_type == ICMP_ECHOREPLY) && (icmp->icmp_id == pid))
    {
        tvsend = (struct timeval *)icmp->icmp_data;
        tv_sub(&tvrecv,tvsend); //接收和发送的时间差
        //以毫秒为单位计算rtt
        rtt = tvrecv.tv_sec*1000 + tvrecv.tv_usec/1000;
        temp_rtt[nreceived] = rtt;
        all_time += rtt;    //总时间
        //显示相关的信息
        printf("%ld bytes from %s: icmp_seq=%u ttl=%d time=%.1f ms\n",
               len,inet_ntoa(from.sin_addr),
               icmp->icmp_seq,ip->ip_ttl,rtt);
        Ping *ping = [Ping getInstance];
        if ([ping respondsToSelector:@selector(receiveData:)] && len>=0) {
            NSString *string = [NSString stringWithCString:recvpacket encoding:NSUTF8StringEncoding];
            NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
            [ping receiveData:data];
        }
        return 0;
        
    }
    else return -1;
}

/****检验和算法****/
unsigned short cal_chksum(unsigned short *addr,int len)
{
    int nleft = len;
    int sum = 0;
    unsigned short *w = addr;
    unsigned short check_sum = 0;
    
    while(nleft>1)      //ICMP包头以字（2字节）为单位累加
    {
        sum += *w++;
        nleft -= 2;
    }
    
    if(nleft == 1)      //ICMP为奇数字节时，转换最后一个字节，继续累加
    {
        *(unsigned char *)(&check_sum) = *(unsigned char *)w;
        sum += check_sum;
    }
    sum = (sum >> 16) + (sum & 0xFFFF);
    sum += (sum >> 16);
    check_sum = ~sum;   //取反得到校验和
    return check_sum;
}

//两个timeval相减
void tv_sub(struct timeval *recvtime,struct timeval *sendtime)
{
    long sec = recvtime->tv_sec - sendtime->tv_sec;
    long usec = recvtime->tv_usec - sendtime->tv_usec;
    if(usec >= 0){
        recvtime->tv_sec = sec;
        recvtime->tv_usec = (int)usec;
    }else{
        recvtime->tv_sec = sec - 1;
        recvtime->tv_usec = (int)-usec;
    }
}

@end
