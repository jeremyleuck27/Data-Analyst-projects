#!/usr/bin/env python
# coding: utf-8

# In[238]:


from bs4 import BeautifulSoup
import requests


# In[240]:


url = 'https://en.wikipedia.org/wiki/List_of_largest_companies_in_the_United_States_by_revenue'
page = requests.get(url)
soup = BeautifulSoup(page.text, 'html')


# In[241]:


soup.find('table')


# In[244]:


soup.find('table', class_ = 'wikitable sortable')


# In[246]:


table = soup.find_all('table')[0]


# In[248]:


print(table)


# In[250]:


table.find_all('th')


# In[252]:


world_titles = table.find_all('th')


# In[254]:


world_table_titles = [title.text.strip() for title in world_titles]


# In[ ]:





# In[257]:


print(world_table_titles)


# In[259]:


import pandas as pd


# In[261]:


df = pd.DataFrame(columns = world_table_titles)
df


# In[271]:


column_data = table.find_all('tr')


# In[283]:


for row in column_data[1:]:
    row_data = row.find_all('td')
    individual_row_data = [data.text.strip() for data in row_data]

    length = len(df)
    df.loc[length] = individual_row_data


# In[285]:


df


# In[303]:


df.to_csv(r'Documents/Data Analysis Learning/Python /Companies.csv', index = False)


# In[ ]:





# In[ ]:





# In[ ]:




