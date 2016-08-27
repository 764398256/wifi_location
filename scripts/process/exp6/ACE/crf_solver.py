import numpy as np

class CRF_SOLVER(object):
    def __init__(self, _lambda = 0.1, trainX ):
        self._lambda = _lambda
        self.trainX = trainX
        self.trainY = trainY
    def DP(self):
            
        
    def object_function(self, trainX, trainY, w):
        (sample_len, tuple_num) = np.zeros( trainX )
        L = self._lambda * np.norm(w)
        
        for i in xrange(sample_len):
            (node_feature, edges, edge_feature) = trainX[i]
            (label_num, num_node_features) = np.shape(node_feature)
            (edge_num, num_edge_features) = np.shape(edge_feature)
            summ += [ np.inner(w[:num_node_features], node_feature[j][:]) if trainY[i][j] == 1 for j in xrange(label_num)] 
            summ += [ np.inner(w[num_node_features: num_node_features*2], node_feature[j][:]) if trainY[i][j] == 0 for j in xrange(label_num)] 
            offset = num_node_features*2
            d = [(0,0), (0,1),(1,0), (1,1)]
            summ += [ np.inner(w[offset + l*len(d): offset + l*len(d) + num_edge_features], edge_feature[j][:]) if (trainY[j][t[0]], trainY[j][t[1]]) == k for l,k in enumerate(d) for j,t in enumerate(edges)] 

    def gradientL(self,w)
        2* 
    def BFGS(self,D,epsilon=0.001):
        w_new = np.zeros(D)
        B_new = np.identity(D)
        while sum(abs(d)) < epsilon:
            w_old, B_old = w_new, B_new
            d = np.linalg.inv(B_old)* gradientL(w_old)
            mu = max_step(w_old,d)
            w_new = w_old + mu* d
            y = gradientL(w_new) - gradientL(w_old)
            # tmp terms: 
            dyt = np.dot(d, y.transpose())
            ddt = np.dot(d, d.transpose())
            ytd = np.dot(y.transpose(), d)
            eigvec = np.identity(D) - dyt/ytd
            B_new = np.dot(np.dot(eigvec, B_old), eigvec) + mu*ddt/ytd
            
        return w_new

    def max_step(self, w_old, d):

