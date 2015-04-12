function data_new = normalize(data)


for i = 1 : size(data,2)
        data_new(:,i) = data(:,i)/max(norm(data(:,i)),1e-12);
end
    
end