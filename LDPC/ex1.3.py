import numpy as np
H=np.loadtxt('H_correct.txt')
y=np.loadtxt('y1.txt')

n_iter,output,result = LDPC_Decoder(y, H, p=0.1)
print(n_iter)
" ".join(str(x) for x in result)

def LDPC_Decoder(y, H, p=0.1, max_iter=20):
    """
    Based on sum-product message passing / Loopy Back Propagation
    
    parameters
    y: received codeword matrix
    H: LDPC matrix
    p: noise ratio
    max_iter: maximum iteration
    r: matrix of rise distribution of p(y|xn=0,1)
    E: factor-to-variable generated matrix
    L: variable-to-factor generated matrix
    M: message matrix
    """
    n_iter=1
    output=-1
    rise,Msg=BSC_initial(y,H) #stage1:initialization
    
    for i in range(max_iter):
        f2v=factor2Var(H,Msg) # stage2: factor-to-variable
        v2f=var2factor(rise,f2v) # stage3: variabel-to-factor
        result = [0 if v2f[i]>0 else 1 for i in range(len(v2f))]
        if sum(H.dot(result)%2)==0:
            output=0   # success
            return n_iter, output, result
        else:
            output=-1
            
        n_iter=n_iter+1 
        Msg=update_M(rise,Msg,f2v,H)#update received message
    
    return n_iter, output, result

def BSC_initial(y, H, p=0.1):
    r=np.zeros((len(y)))   #rise of distribution
    #for BSC, log(P(y|x))= (x-y)(x-y+1)log(p/1-p)
    p1 = np.log(p/(1-p)) #x=y
    p2 = np.log((1-p)/p) #x!=y
    r = [p1 if y[i]==1 else p2 for i in range(len(y))]
    M=np.zeros((H.shape))
    
    #message passing from y to H
    for i in range(H.shape[0]):
        for j in range(H.shape[1]):
            if H[i,j]==1:
                M[i,j]=r[j]
    
    return r,M

def factor2Var(H,M):
    m,n=H.shape
    E=np.zeros((m,n))
    #passing all factor-to-variable ones
    for i in range(m):
        o=get_ones(H[i,:])
        for j in o:
            result = 1
            for k in o:
                if k != j:
                    result = result * np.tanh(M[i,:][k]/2)
            
            E[i,j]=np.log((1+result)/(1-result))
            
    return E

def var2factor(r,E):
    m,n=E.shape
    L=np.zeros((n,1))
    #variabel-to-factor message passing
    L = [r[i]+np.sum(E,0)[i] for i in range(n)]
    
    return L

def update_M(r,M,E,H):
    m,n=M.shape
    for i in range(n):
        o=get_ones(H[:,i])
        for j in o:
            result = 0
            for k in o:
                if k != j:
                    result = E[:,i][k]+result
            M[j,i]=r[i]+result
            
    return M

def get_ones(o):
    idx = 0
    l=[]
    list_of_o=list(o)
    for i in range(list_of_o.count(1)):
        new_list = list_of_o[idx:]
        step = new_list.index(1) + 1
        l.append(idx + new_list.index(1))
        idx += step
        
    return l