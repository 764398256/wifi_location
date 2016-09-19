import numpy as np

class CRF_SOLVER(object):
    def __init__(self, _lambda = 0.1, histo, grid, edges, mapper ):
        self.grid = grid
        self._lambda = _lambda
        self.histo = histo
        (voxel_num, stream_num, d, nbins) = np.shape(self.histo)
        self.edges = self.generate_node
        self.n_nodes = voxel_num
        self.n_edges = len(edges)
        self.n_states = 2
        self.rss_start = -30
        self.rss_end = 30
        self.rss_step = 0.5
        self.nbins = (self.rss_end - self.rss_start)/self.rss_step

        
    def rss_range(self, val):
        return np.floor(( val - self.rss_start) / (self.rss_end - self.rss_start ) * self.nbins ) 
        
    def objective_and_gradients_batch(self, seq, trainY, w):
        (sample_len, tuple_num) = np.zeros( trainX )
        L = self._lambda * np.norm(w)
        logl = 0
        sigma2 = 10
        states = self.n_states
        g = np.zeros(w.size())
        for i in xrange(sample_len):
            (node_feature, edges, edge_feature) = trainX[i]
            labels = trainY[i]
            (label_num, num_node_features) = np.shape(node_feature)
            (edge_num, num_edge_features) = np.shape(edge_feature)
            ## compute M
            Md = self.compute_M(self.grid, w, edge, seq, labels, states)
            ## compute alpha score
            alpha = self.compute_alpha_score(self.grid, states, Md)
            ## compute beta score
            beta = self.compute_beta_score(self.grid, states, Md)
            ## compute normalize term
            Z = 1.
            for M in Md:
               Z *= M
            ## compute marginal probability
            prod, pairwise_prod = self.compute_marginal(self.grid, edges, Z, alpha, beta, Md) 
            ## compute 
            ## compute gradient
            g,logp = self.score(g, self.grid, states, seq, labels, prod, pairwise_prod)
            for k in xrange(len(g)):
                g[k] -= w[k]/sigma2
            logp += -log(Z)
            logl += logp
         logl -= sum(w**2)/sigma2
         return g, logl

    def BFGS(self,D,epsilon=0.001):
        # D is 
        w_new = np.zeros(D)
        B_new = np.identity(D)
        while sum(abs(d)) < epsilon:
            w_old, B_old = w_new, B_new
            self.objective_and_gradients_batch()
            d = np.linalg.inv(B_old) * gradientL(w_old)
            mu = max_step(w_old,d)
            w_new = w_old + mu* d
            y = gradientL(w_new) - gradientL(w_old)
            # tmp terms: 
            dyt = np.dot(d, y.transpose())
            ddt = np.dot(d, d.transpose())
            ytd = np.dot(y.transpose(), d)
            eigvec = np.identity(D) - dyt/ytd

            B_new = np.dot(np.dot(eigvec, B_old), eigvec) + mu * ddt / ytd
        return w_new
        
    def unary_func(self, node, dim, state, value ):
        return np.log(self.histo[node][dim][state][self.rss_range(value)])

    def pairwise_func(self, edge, dim, state, value):
        return -(1 + np.exp(-( self.histo[edge[0]][dim][state[0]][self.rss_range(value[0])] 
                            - self.histo[edge[1]][dim][state[1]][self.rss_range(value[1])]
                            )**2))/2 
    def get_unary_features(self, data, nodes, labels):
        num_unary_feature = len(data)
        return np.array([ [ self.unary_func(node, j, state, data[j] )
                                        for j in xrange(num_unary_feature) ]
                                        for node, state in zip(nodes, labels)) 
                                    ])
    def get_pairwise_features(self, data, edges, labels):
        num_pairwise_feature = len(data)
        return np.array([[ self.pairwise_func(edge, j, [labels[edge[0]], labels[edge[1]]], data[j] )
                                        if labels[edge[0]] != labels[edge[1]] else 0 
                                        for j in xrange(num_pairwise_feature) ] 
                                        for edge in edges ])


        
    def unary_sum(self, w, data, nodes, labels):
        _sum = 0
        num_unary_feature = len(data)
        num_nodes = len(nodes)
        #for state in xrange(states):
        #    _sum += sum([ w[state*num_unary_feature + k]* unary_features[i][k] if label[i] == state for k in xrange(num_unary_feature) for i in xrange(num_nodes) ])
        unary_features = self.get_unary_features(data, nodes, labels)
        _sum += sum([ w[k]* unary_features[i][k] for k in xrange(num_unary_feature) for i in xrange(num_nodes) ])
        return _sum

    def pairwise_sum(self, w, data, edges, labels):
        num_pairwise_feature = len(seq) 
        num_edge = len(edges)
        _sum = 0
        #for state1,state2  in zip(xrange(states), xrange(states)):
        #    state_index = state1* states + state2
        #    _sum += sum([ w[state_index * num_pairwise_feature + k]* pairwise_features[i][k] if labels[t[0]] == state1 and labels[t[1]] == state2 for k in xrange(num_pairwise_feature) for i, t in enumerate(edges) ])
        pairwise_features = self.get_pairwise_features(data, edges, labels)
        _sum += sum([ w[k]* pairwise_features[i][k] for k in xrange(num_pairwise_feature) for i, t in enumerate(edges) ])
        return _sum

    def compute_M(self, grid, w, edge, seq, labels, states):
        (M, N) = np.shape(grid)
        (n_nodes, num_unary_features) = np.shape(unary_features)
        (num_edges, num_pairwise_features) = np.shape(pairwise_features)
        Md = [] 
        pre_nodes = []
        pre_labels = [-1]
        for d in xrange(1, M+N):
            cur_nodes = [ self.map_index[ d - 1 - i ][i] for i in xrange(d) ]    
            sub_edges_index = [ i if t[0] in pre_nodes and t[1] in cur_nodes or t[1] in pre_nodes and t[0] in cur_nodes for i, t in enumerate(edges) ]
            sub_edges = edges[sub_edges_index]
            sub_edge_features = pairwise_features[sub_edges_index]
            cur_labels = list(itertools.product([i for i in xrange(states)], repeat=len(cur_nodes))) 
            Md_tmp = zeros(states ** pre_nodes, states ** cur_nodes)
            for j, curl in enumerate(cur_labels):
                u_sum = self.unary_sum(w[0 : num_unary_features], seq, cur_nodes, curl)
                for i, prel in enumerate(pre_labels):
                    label = zeros(n_nodes)
                    label[cur_nodes] = curl
                    label[pre_nodes] = prel
                    #unary_sum = self.unary_sum(w[: num_unary_features* states], unary_features[cur_nodes], states, curl)
                    #pairwise_sum = self.pairwise_sum(w[num_unary_feature,:], sub_edge_features, sub_edges, states, labels)
                    p_sum = self.pairwise_sum(w[num_unary_feature:], seq, sub_edges, label)
                    Md_tmp[i][j] = np.exp(u_sum + p_sum)
            Md.append(np.array(Md_tmp)) 
            pre_nodes = cur_nodes
            pre_labels = cur_labels
         return Md
    def compute_alpha_score(self, grid, states, Md):
        (M, N) = np.shape(grid)
        alpha = []
        # initial
        alpha.append([1])
        for d in xrange(1, M + N + 1):
            alpha.append(np.dot( alpha[d-1], Md[d]) )
        return alpha

    def compute_beta_score(self, grid, states, Md):
        (M, N) = np.shape(grid)
        beta = []
        # initial
        bata.append([1])
        for d in xrange(1, M + N + 1):
            beta.append(np.transpose(np.dot(Md[M + N + 1 - d], beta[d-1]))
        return beta.inverse()

    def compute_marginal(self, grid, edges, Z, alpha, beta, Md):
        (M, N) = np.shape(grid)
        num_edges = len(edges)
        prod = np.zeros((states, M*N) )
        pairwise_prod = np.zeros((states** 2, num_edges ))
        pre_nodes = []
        pre_labels = [-1]
        for d in xrange(1, M + N + 1 ):
            cur_nodes = [ self.map_index[ d - 1 - i ][i] for i in xrange(d) ]    
            sub_edges_index = [ i if t[0] in pre_nodes and t[1] in cur_nodes or t[1] in pre_nodes and t[0] in cur_nodes for i, t in enumerate(edges) ]
            sub_edges = edges[sub_edges_index]
            sub_edge_features = pairwise_features[sub_edges_index]
            cur_labels = list(itertools.product([i for i in xrange(states)], repeat=len(cur_nodes))) 
            pre_labels = list(itertools.product([i for i in xrange(states)], repeat=len(pre_nodes))) 
            # marginal for unary
            for ci, curl in enumerate(cur_labels):
                for i, node in enumerate(cur_nodes):
                    for state in xrange(states):
                        if curl[i] == state:
                            prod[state][node] += alpha[d][ci]* beta[d][ci]/Z
            for si, sub_edge in enumerate(sub_edges):
                (s, t) = sub_edge
                for ci, curl in enumerate(curl_labels):
                    for pi, prel in enumerate(pre_labels):
                        for state1 in xrange(states):
                            for state2 in xrange(states):
                                state_id = state1* states + state2
                                edge_id = edges.index(sub_edge)
                                ni = cur_nodes.index(s)
                                pni = pre_nodes.index(t)
                                if curl[ni] == state1 and prel[pni] == state2:
                                    pairwise_prod[state_id][edge_id] += alpha[d-1][ci]* Md[ci][[pi] * beta[d][pi]

        return prod, pairwise_prod 

    def score(self, g, grid, states, seq, label, prod, pairwise_prod):
        (M, N) = np.shape(grid)
        (n_nodes, num_unary_features) = np.shape(unary_features)
        (num_edges, num_pairwise_features) = np.shape(pairwise_features)
        Md = [] 
        logp = 0
        pre_nodes = []
        pre_labels = [-1]
        for d in xrange(1, M+N):
            cur_nodes = [ self.map_index[ d - 1 - i ][i] for i in xrange(d) ]    
            sub_edges_index = [ i if t[0] in pre_nodes and t[1] in cur_nodes or t[1] in pre_nodes and t[0] in cur_nodes for i, t in enumerate(edges) ]
            sub_edges = edges[sub_edges_index]
            sub_edge_features = pairwise_features[sub_edges_index]
            cur_labels = list(itertools.product([i for i in xrange(states)], repeat=len(cur_nodes))) 
            ## empirical labels
            em_unary_features = self.get_unary_features(seq, cur_nodes, label)
            ## probability labels
            pb_unary_features = self.get_unary_features(seq, cur_nodes, )
            for k in xrange(num_unary_feature):
                g[k] += sum( em_unary_features[:,k] ) - sum([ (self.get_unary_features(seq, node, state))[0][k]* prod[state][node] for node in cur_nodes for state in xrange(states) ])   
            pb_label = label
            em_pairwise_features = self.get_pairwise_features(seq, sub_edges, label)
            logp += sum(sum(em_unary_features)) + sum(sum(em_pairwise_features))
            for k in xrange(num_pairwise_features):
                tmp = 0
                tmp += sum(em_pairwise_features[:,k]) 
                for edge in sub_edges:
                    for state1 in xrange(states):
                        for state2 in xrange(states):
                            pb_label[edge[0]] = state1
                            pb_label[edge[1]] = state2
                            cur_f = self.get_pairwise_features(seq, edge, pb_label)
                            tmp -= cur_f[0][k]* pairwise_prod[state1* states + state2][edge]
                g[k + num_unary_features] += tmp
        return g, logp

if __name__ == '__main__':
        
    file_p = '../../../data/exp6/mat/'
    histo = loadmat(file_p + 'histo.mat')
    edges = loadmat(file_p + 'edges.mat')
    samples = loadmat(file_p + 'sample.mat')
    #test = loadmat(file_p + 'M_test_fg_three_13_17_112.mat')
    test = loadmat(file_p + 'M_test_fg_three_13_17_112.mat')
    sample_label = loadmat(file_p + 'sample_label.mat')
    histo = histo['histo']
    edges = edges['edges']
    samples = samples['M']
    test_case = test['M_test']
    sample_label = sample_label['label']
    train_flag = 0
    
    model_file = 'model.pkl'
    if train_flag:
        crf_instance = CRF(histo, edges)
        crf_instance.trainer(trainX, trainY)
        pickle_save(model_file,crf_instance)
        print crf_instance.learner.score(trainX, trainY), crf_instance.predict(trainX[0:2], True)
        pdb.set_trace()

    else:
        crf_instance = pickle_load(model_file)

    [trainX, trainY] = crf_instance.generate_data(samples, sample_label)
    print crf_instance.predict(trainX[0:2], True)
    pdb.set_trace()
    print crf_instance.predict(samples[0], False) 
#labels = crf_instance.predict(test_case, 1)
#crf_instance.score(trainX, trainY)
#print crf_instance.predict(trainX)





