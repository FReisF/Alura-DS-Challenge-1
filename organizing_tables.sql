create schema analise_risco;

#Exploratorio das tabelas
#New archive need to be imported the original one is smaller
#Traduzindo os nomes de colunas para Portugues
alter table analise_risco.dados_mutuarios
	rename column person_emp_length to tempo_trabalho,
	rename column person_age to idade_pessoa,
	rename column person_income to salario_pessoa,
	rename column person_home_ownership to propriedade_pessoa,
	rename column person_id to id_pessoa;
	#Traduzindo valores em ingles 
		update analise_risco.dados_mutuarios
			set propriedade_pessoa =  'Alugada'
        where propriedade_pessoa like 'Rent';
        
        update analise_risco.dados_mutuarios
			set propriedade_pessoa = 'Propria'
        where propriedade_pessoa = 'Own';
        
        
			alter table analise_risco.dados_mutuarios
			modify propriedade_pessoa varchar(12);
        
        update analise_risco.dados_mutuarios
			set propriedade_pessoa = 'Hipotecada'
        where propriedade_pessoa like 'Mortgage';
        
        update analise_risco.dados_mutuarios
			set propriedade_pessoa = 'Outros Casos'
        where propriedade_pessoa like 'Other';

alter table analise_risco.emprestimos
	rename column loan_id to id_emprestimo,
	rename column loan_intent to motivo_emprestimo,
	rename column loan_grade to nivel_emprestimo,
	rename column loan_amnt to total_emprestimo,
	rename column loan_int_rate to taxa_juros,
	rename column loan_status to possibilidade_inadimplencia,
	rename column loan_percent_income to renda_percentual;
	
    #Pessoal (Personal), Educativo (Education), Médico (Medical), Empreendimento (Venture), 
    #Melhora do lar (Homeimprovement), Pagamento de débitos (Debtconsolidation)
	update analise_risco.emprestimos
		set motivo_emprestimo = 'Pessoal'
	where motivo_emprestimo like 'Personal';
	
    update analise_risco.emprestimos
		set motivo_emprestimo = 'Educativo'
	where motivo_emprestimo like 'Education';
    
    update analise_risco.emprestimos
		set motivo_emprestimo = 'Medico'
	where motivo_emprestimo like 'Medical';
    
    update analise_risco.emprestimos
		set motivo_emprestimo = 'Empreendimento'
	where motivo_emprestimo like 'Venture';
    
    update analise_risco.emprestimos
		set motivo_emprestimo = 'Melhora do lar'
	where motivo_emprestimo like 'Homeimprovement';
    
    update analise_risco.emprestimos
		set motivo_emprestimo = 'Pagamento de debitos'
	where motivo_emprestimo like 'Debtconsolidation';
	
    update analise_risco.emprestimos
		set motivo_emprestimo = 'Pessoal'
	where motivo_emprestimo like 'Personal';
    
    
alter table analise_risco.historicos_banco
	rename column cb_id to id_historico,
	rename column cb_person_default_on_file to inadimplencia_historico,
	rename column cb_person_cred_hist_length to tempo_ultimo_credito;
	
    alter table analise_risco.historicos_banco
		modify inadimplencia_historico varchar(3);
        
    update analise_risco.historicos_banco
		set inadimplencia_historico = 'sim'
	where inadimplencia_historico like '%Y%';
	
    update analise_risco.historicos_banco
		set inadimplencia_historico = 'nao'
	where inadimplencia_historico like '%N%';

alter table analise_risco.ids
	rename column cb_id to id_historico,
	rename column loan_id to id_emprestimo,
	rename column person_id to id_pessoa;

select * from analise_risco.dados_mutuarios;
	select * from analise_risco.dados_mutuarios where id_pessoa is null; #No null values
		select id_pessoa,count(*) from analise_risco.dados_mutuarios group by 1 order by 2 desc; #There are empty IDs, all others unique
			select distinct propriedade_pessoa from analise_risco.dados_mutuarios;  
            
select * from analise_risco.emprestimos;
	select * from analise_risco.emprestimos where id_emprestimo is null; #No null values
		select id_emprestimo,count(*) from analise_risco.emprestimos group by 1 order by 2; #No empty, all others unique
			select distinct motivo_emprestimo, nivel_emprestimo from analise_risco.emprestimos;
            
select * from analise_risco.historicos_banco;
	select * from analise_risco.historicos_banco where id_historico is null; #No null values
		select id_historico,count(*) from analise_risco.historicos_banco group by 1 order by 2; #No empty, all others unique
			select distinct inadimplencia_historico from analise_risco.historicos_banco;#All good
#####################################################################################################################################
#Check for distinct values on each column
		select distinct tempo_trabalho from analise_risco.dados_mutuarios order by 1;
			#There are nullvalues in working time -> Replace them to 0
            update analise_risco.dados_mutuarios set tempo_trabalho = 0 where tempo_trabalho is null;
			#There are values with 123 working time -> Check the age
				select * from analise_risco.dados_mutuarios where tempo_trabalho > 100;
				# Two people of early age -21 and 22- work time is max 5 and 6 years
                update analise_risco.dados_mutuarios set tempo_trabalho = 5 where tempo_trabalho = 123;
                
        select distinct idade_pessoa from analise_risco.dados_mutuarios order by 1;
			#found null values on age and people above 120 years
			select * from analise_risco.dados_mutuarios where idade_pessoa is null or idade_pessoa = 0;
			#I will add 20 years + working time to the people with age null or 0
			update analise_risco.dados_mutuarios set idade_pessoa = 0 where idade_pessoa is null;
			update analise_risco.dados_mutuarios set idade_pessoa = 20 + tempo_trabalho where idade_pessoa = 0;
            
            #find out more about the oldies
            select * from analise_risco.dados_mutuarios where idade_pessoa > 120;
				#They all have max 12 years of work so I am going to change their age to 20 + work time as well
				update analise_risco.dados_mutuarios set idade_pessoa = 20 + tempo_trabalho where idade_pessoa > 120;
                
        select distinct salario_pessoa from analise_risco.dados_mutuarios order by 1;
			#Only weird data is null so I will just change that to 0 as the person can have money saved or inherited or whatever
			update analise_risco.dados_mutuarios set salario_pessoa = 0 where salario_pessoa is null;
        
        select distinct propriedade_pessoa from analise_risco.dados_mutuarios order by 1;
        #Some empty values so I will just  check who are these people
        select propriedade_pessoa,count(id_pessoa) from analise_risco.dados_mutuarios group by propriedade_pessoa; 
        update analise_risco.dados_mutuarios set propriedade_pessoa = 'Outros Casos' where propriedade_pessoa 
        not in ('Alugada','Propria','Hipotecada','Outros Casos');
        
        
        select distinct motivo_emprestimo from analise_risco.emprestimos order by 1;
		update analise_risco.emprestimos set motivo_emprestimo = 'Outro' where
        motivo_emprestimo not in ('Educativo','Empreendimento','Medico','Melhora do lar','Pagamento de debitos','Pessoal');

#####################################################################################################################################    


create table analise_risco.total as
select dados_mutuarios.id_pessoa,
	dados_mutuarios.idade_pessoa,
    dados_mutuarios.salario_pessoa,
    dados_mutuarios.propriedade_pessoa,
    dados_mutuarios.tempo_trabalho,
    emprestimos.id_emprestimo,
    emprestimos.motivo_emprestimo,
    emprestimos.nivel_emprestimo,
    emprestimos.total_emprestimo,
    emprestimos.taxa_juros,
    emprestimos.possibilidade_inadimplencia,
    emprestimos.renda_percentual,
    historicos_banco.id_historico,
    historicos_banco.inadimplencia_historico,
    historicos_banco.tempo_ultimo_credito
from analise_risco.ids id                            
join analise_risco.dados_mutuarios dados_mutuarios on id.id_pessoa = dados_mutuarios.id_pessoa
join analise_risco.emprestimos emprestimos on id.id_emprestimo = emprestimos.id_emprestimo
join analise_risco.historicos_banco historicos_banco on id.id_historico = historicos_banco.id_historico;  
#############################################################################################

update analise_risco.total
set salario_pessoa = total_emprestimo/renda_percentual
where (salario_pessoa is null or  salario_pessoa = 0) and total_emprestimo is not null and renda_percentual is not null;

update analise_risco.total
set total_emprestimo = salario_pessoa * renda_percentual
where total_emprestimo is null and salario_pessoa is not null and salario_pessoa != 0 and renda_percentual is not null;    

update analise_risco.total
set renda_percentual = total_emprestimo/salario_pessoa
where renda_percentual is null and salario_pessoa is not null and salario_pessoa != 0 and total_emprestimo is not null;

select count(*) #salario_pessoa,total_emprestimo,renda_percentual
from analise_risco.total
where (salario_pessoa is null or salario_pessoa = 0)
and (total_emprestimo is null or renda_percentual is null);

select count(*) #salario_pessoa,total_emprestimo,renda_percentual
from analise_risco.total
where salario_pessoa is null or salario_pessoa = 0;

#56 entries that cannot be calculated back same as the number of 0 salaries
#Exporting to csv file	
