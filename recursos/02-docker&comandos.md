## Inslação do Docker 

Para esse capitulo vamos deixar o sistema com ar mais dev. Vamos instalar alguns pacotes como: `git`, e `zsh`.

Instalamos o `zsh` e o `git`, e um editor de texto simpatico.

[zsh](imagens/dev.png)

**Configure seu git com os comandos abaixo:**

```bash
paulo@debian13:~$ git config --global user.name "teu-nome-aqui"
paulo@debian13:~$ git config --global user.email "teu-email-aqui"
paulo@debian13:~$ git config --global core.editor "vim"
paulo@debian13:~$ git config --global init.defaultBranch main
```

**Clonamos o repositório zsh.**

[zsh](imagens/dev1.png)

**Aceitamos as mudanças no terminal**

[zsh](imagens/dev2.png)

**Editamos o arquivo `.zshrc`, e mudamod o tema para `agnoster`.

[zsh](imagens/dev3.png)

**Instalamos as fontes para o tema.**

[zsh](imagens/dev4.png)

> Apos fazer logout, as mudanças entram em vigor.

[zsh](imagens/dev5.png)

Vamos continuar...

**Existem duas maneiras de instalar o Docker**

- **1ª - Script de conveniência**: Para ambientes de estudos e testes, não recomendado para ambientes de produção. O script está [aqui](curl -fsSL https://get.docker.com -o get-docker.sh), esse script instala o docker com todas as configrações padrão. Ou pode ser visto neste [endereço](https://get.docker.com/).

[Docker-install](imagens/docker.png)

- **2ª - Repositório manual**: Método oficial e cobrado em para prova de certificação.

Iremos efetuar a instalação da maneira tradicional nas máquinas `node01` e `node02` e com o script de conveniência na máquinas `master` para fim de exemplo de como funcina o script.

### Instalação do script de Conveniência.

Os passos a seguir vão ser executados na máquina `master` e, não esqueça de abrir um terminal novo executar o comando `vagrant ssh <host>`

[Docker-install](imagens/docker1.png)

**Acessando a maguina:**

[Docker-install](imagens/docker2.png)

A Docker disponibiliza um `script de conveniência`, que trata-se de uma maneira simples e rápida para instalar o Docker para ambientes de desenvolvimento, este script faz a validação da distribuição Linux bem como instala os pacotes necessários para o funcionamento do Docker. 

Antes é claro alguns ajustes na maquina:

- Atualização das listas de repositório

[Docker-install](imagens/docker3.png)

- Instalar as atualizações 

[Docker-install](imagens/docker4.png)
...
[Docker-install](imagens/docker5.png)


```bash
vagrant@master:~$ sudo nano /etc/apt/sources.list
```
img-comentario das listas backport.

- Instalação de pacotes básicos.

[Docker-install](imagens/docker6.png)

Para instalar o Docker através do script de conveniência basta executar os comandos:

[Docker-install](imagens/docker7.png)

Poderiamos executar direto:

```bash
vagrant@master:~$ curl -fsSl https://get.docker.com | sudo bash
```

Vamos confirmar a instalação com o comando `docker system info`.

[Docker-install](imagens/docker8.png)

> Em sistemas RHEL like, precisamos habilitar e iniciar o serviço após a instalação do mesmo

```bash
$ sudo systemctl --enable now docker
$ sudo systemctl start docker
```

Assim foi a istação do docker com o `script de conveniência`.

### Instalação manual no Debian

A pagina de instalação fica [aqui](https://docs.docker.com/engine/install)

Para isso vamos acessar a maquina `node01`, com o comando `vagrant up node01`. 

Abaixo tem o processo completo da inicialização da maquina.

Uma vez conectado na máquina docker, execute os seguintes comandos:

Esses comandos são o procedimento padrão para preparar o seu sistema (neste caso, um Debian ou derivado) para baixar o Docker diretamente da fonte oficial, garantindo que o software seja autêntico e atualizado.

- Atualiza a lista de pacotes dos repositórios

[Docker-install](imagens/docker9.png)

- Permite que o sistema verifique a validade de certificados de sites (segurança SSL/TLS).

[Docker-install](imagens/docker10.png)

- Cria a pasta onde as chaves de segurança de terceiros serão guardadas.

[Docker-install](imagens/docker11.png)

- Baixa a chave pública oficial do Docker. E altera as permissões do arquivo da chave para garantir que todos os usuários (incluindo o serviço de atualização do sistema) consigam ler (a+r) o arquivo.

[Docker-install](imagens/docker12.png)

- Cria um novo arquivo de "fonte" (source). Basicamente, você está dizendo ao seu computador: "Ei, além dos servidores padrão, agora você também pode buscar programas neste endereço do Docker".

[Docker-install](imagens/docker13.png)

- Podemos atualizar as listas de repositórios novamente.

[Docker-install](imagens/docker14.png)

Note as linhas `Get:1` e `Get:4:` elas confirmam que o seu Debian (bookworm) agora está "conversando" com os servidores oficiais do Docker e baixando a lista de pacotes disponíveis de lá. Como não houve erros de "GPG" ou "404", a chave e o repositório que adicionamos estão corretos.

- Instalando os componentes principais do motor do Docker.

[Docker-install](imagens/docker15.png)

**Aqui está o que cada um desses pacotes faz no seu sistema:**

- **docker-ce:** O "Community Edition". É o motor (engine) propriamente dito, o serviço que roda em segundo plano e gerencia os containers.
- **docker-ce-cli:** A ferramenta de linha de comando que você usa para digitar docker run, docker ps, etc. Ela se comunica com o motor.
- **containerd.io:** O "executor" de baixo nível. O Docker delega a gestão do ciclo de vida dos containers (iniciar, parar) para ele.

Instalação finalizada com sucesso.

[Docker-install](imagens/docker16.png)

Após a conclusão da instalação, podemos configurar agora nosso usuário para fazer parte do grupo `docker`, isso garantirá que possamos executar os comandos do docker sem a necessidade de elevar os privilégios.

[Docker-install](imagens/docker17.png)

Vamos também instalar o recurso de `Bash Completion` através do comando:

```bash
$ sudo curl https://raw.githubusercontent.com/docker/machine/v0.16.0/contrib/completion/bash/docker-machine.bash -o /etc/bash_completion.d/docker-machine
```

[Docker-install](imagens/docker18.png)

Saia do terminal e inicie uma nova sessão e o usuário já poderá executar o comando como super user.

### Teste de Execução

Para garantirmos que o docker foi instalado corretamente e está funcional, podemos rodar nosso primeiro container e verificar o retorno na tela.

```bash
$ docker container run --rm -it hello-world
```

[Docker-install](imagens/docker19.png)

**Aqui está o que aconteceu nos bastidores, linha por linha:**

1. **A busca local (Unable to find image...)**

O Docker primeiro olhou dentro do seu próprio computador (o node01) para ver se você já tinha baixado a imagem hello-world antes. Como ele não a encontrou, ele avisou que precisaria buscar fora.

2. **O download (Pulling from library/...)**

Como não estava localmente, o Docker conectou-se ao Docker Hub.

> Note que ele baixou a versão latest (a mais atual), já que você não especificou uma versão.

3. **A criação e execução**

Após o download, o Docker:

- Criou um container baseado nessa imagem.
- Executou o comando que estava programado dentro dela (que é apenas imprimir esse texto de boas-vindas).
- Encaminhou a saída do container diretamente para o seu terminal.

4. **O papel das flags:**

As duas flags são muito importantes no comando:

- **--rm:** Isso diz ao Docker: "Assim que este container terminar de rodar, apague-o da memória". Isso evita que seu disco fique cheio de containers parados e inúteis.
- **-it:** É a combinação de -i (interativo) e -t (tty/terminal). Basicamente, garante que você consiga ver o que o container está "falando" e interagir com ele se necessário.

**Esse teste confirmou três coisas cruciais:**

- O serviço do Docker está ativo.
- Sua conexão com a internet está autorizada a baixar imagens do Docker Hub.
- O seu usuário já tem permissão para rodar comandos (já que você não precisou usar sudo desta vez!).

### Instalando Docker no almalinux

Vamos aqui repetir todo processo mais mudndo para o almalinux.

Primeiramente vamos acessar a máquina `node02` e um pequeno ajuste pode ser feito.

Uma vez conectado na máquina docker, execute os seguintes comandos:

**Atualização do repositório**

[Docker-install](imagens/docker21.png)

**Instalação de pacotes utéis.**

[Docker-install](imagens/docker22.png)

**O que são esses pacotes:**

- O `yum-utils` é um conjunto de ferramentas e extensões para o gerenciador de pacotes yum. Ele não instala um programa específico, mas dá "superpoderes" ao terminal para gerenciar repositórios.
- `EPEL significa Extra Packages for Enterprise Linux`. O que é: É um repositório mantido pela comunidade Fedora que contém pacotes de software de altíssima qualidade que não estão incluídos nos repositórios padrão do Red Hat ou CentOS.

Adicionar os repositório docker no almalinux

`sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo`

[Docker-install](imagens/docker23.png)

Instalação do docker

[Docker-install](imagens/docker24.png)

Instalação completa

[Docker-install](imagens/docker25.png)

Após a conclusão da instalação, podemos configurar agora nosso usuário para fazer parte do grupo `docker`, isso garantirá que possamos executar os comandos do docker sem a necessidade de elevar os privilégios.

[Docker-install](imagens/docker26.png)

> Nos sistemas RHEL like, precisamos habilitar e iniciar o serviço após a instalação do mesmo.

```bash
$ sudo systemctl enable docker
$ sudo systemctl start docker
```
[Docker-install](imagens/docker27.png)

Vamos também instalar o recurso de `Bash Completion` através do comando:

```bash
$ sudo curl https://raw.githubusercontent.com/docker/machine/v0.16.0/contrib/completion/bash/docker-machine.bash -o /etc/bash_completion.d/docker-machine
```

[Docker-install](imagens/docker28.png)

Saia do terminal e inicie uma nova sessão e o usuário já poderá executar o comando como super user.

```bash
$ exit
$ vagrant ssh node02
```

### Teste de Execução

Para garantirmos que o docker foi instalado corretamente e está funcional, podemos rodar nosso primeiro container e verificar o retorno na tela.

`$ docker container run --rm -it hello-world`

[Docker-install](imagens/docker29.png)

> Já vimos a anteriormente o que o comando `$ docker container run --rm -it hello-world` faz.

![Componentes](imagens/01componentes.png)

### Docker Client

O Docker Client é o pacote `docker-ce-cli` ele fornece os comandos do lado do cliente, como por exemplo o comando `docker container run`, que irá interagir com o Docker Daemon

### Docker Daemon 

O Docker Daemon é o pacote `docker-ce` ele é o servidor propriamente dito, que receberá os comandos através do Docker Client e fornecerá os recursos de virtualização a nível de sistema operacional.

### Docker Registry

O Docker Registry é o local de armazenamento de imagens Docker, normalmente o Docker hub, de onde o Docker Daemon receberá as imagens a serem executadas no processo de criação de um container.

## Comandos Essenciais

Iremos agora aprender alguns comandos essenciais do Docker.

O primeiro passo para entendermos os comandos do docker é visualizar sua lista de comandos, iremos falar dos seguintes comandos de gerenciamento ao longo desse material:

- `docker container`
- `docker image`
- `docker network`
- `docker system`
- `docker volume`

Basta rodar o comando `docker help` para termos a ajuda do docker e os principais comandos.

[Docker-install](imagens/docker30.png)

Para cada comando de gerenciamento acima, temos diversos subcomandos a serem executados, muitos deles são parecidos com comandos Linux como por exemplo `ls`, `rm`, dentre outros.

Antigamente o comando utilizado para listar containers era o comando `docker ps` que ainda existe na documentação, porém é indicado que seja utilizado o novo comando `docker container ls`.

[Docker-install](imagens/docker31.png)

> O comando, `ps` é o abreviamento de _Process Status_ enquanto `ls` é o abreviamento de _List_, que é a nova sintaxe de consulta no docker.

Existem diversos outros comandos que iremos ver ao longo do curso.

### Executando comandos

Já conectados, vamos executar os comandos do docker na máquina. 

Para visualizar informações do ambiente, podemos utilizar o comando **docker system info** o qual exibirá informações do Docker como versão, quantidade de containers em execução, storage drivers, entre outros.

```bash
docker system info
docker info
```
[Docker-install](imagens/docker32.png)

_Os comandos listados acima são equivalentes._

> **Nota:** Para listar containers, imagens, redes e volumes no docker, utilizamos o comando **docker** \<comando\> **ls**

- **docker container ls** - lista os containers
- **docker image ls** - lista as imagens
- **docker network ls** - lista as redes
- **docker volume ls** - lista os volumes

Para pesquisar por uma imagem, utilizamos o comando **docker search** e o nome da imagem desejada.

[Docker-install](imagens/docker33.png)

Para fazer o download da imagem utilizamos o comando **docker image pull**.

[Docker-install](imagens/docker34.png)

O mesmo podemos fazer para o rockylinux.

[Docker-install](imagens/docker35.png)

Podemos ver as imagens com o comando abaixo.

[Docker-install](imagens/docker36.png)

Para executar um container, basta utilizamos o comando: `docker container run -dit --name debian1 --hostname c1 debian`.

[Docker-install](imagens/docker37.png)

**Descrição do comando:**

- **docker container run:** Cria e inicia um novo container a partir de uma imagem.
- **-dit** - Executa um container como processo (**d** = Detached), habilitando a interação com o container (**i** = Interactive) e disponibiliza um pseudo-TTY(**t** = TTY)
- **-i + -t:** juntos (-it) são comuns para containers interativos.
- **--name debian1:** Define o nome do container como debian1 (assim você não precisa usar o ID depois)
- **--hostname c1:** Define o hostname dentro do container como c1

Agora que temos nosso primeiro container em execução, podemos listar os containers `docker container ls` e conectar ao mesmo através do comando `docker container attach`.

[Docker-install](imagens/docker38.png)

> Note que ao se conectar ao container a **PS1** será modificada para `root@c1:/#`._

Execute alguns comandos no container:

[Docker-install](imagens/docker39.png)

Esse erro é normal a imagem Debian padrão é bem mínima e não vem com o comando ip instalado.

O comando `ip` faz parte do pacote: `iproute2`.

E ele não vem por padrão em imagens leves do Debian usadas no Docker.

Dentro do container, instale o pacote:

Atualise as listas de repositórios.

[Docker-install](imagens/docker40.png)

Instale o pacote.

[Docker-install](imagens/docker41.png)

Execute o comando.

[Docker-install](imagens/docker42.png)

Podemos ainda executar mais como: `hostname` e `cat /etc/hosts`.

[Docker-install](imagens/docker43.png)

Liste novamente os containers

[Docker-install](imagens/docker44.png)

A diferença entre esses dois comandos é simples, mas muito importante no dia a dia com Docker:

- **docker container ls:** Mostra apenas containers em execução (running). Não retornou nada porque nenhum container está rodando no momento.
- **docker container ls -a:** Mostra todos os containers, incluindo:
	- Em execução
	- Parados (exited)
	-️ Pausados

> Note que agora o container está parado, isto aconteceu pois o processo principal do container recebeu um return code diferente de `0`.

Podemos listar apenas o ID dos containers: `docker container ls -aq`.

[Docker-install](imagens/docker45.png)

Inicie novamente o container e conecte-se ao mesmo

[Docker-install](imagens/docker46.png)

> **Nota:** O comando `docker container start` inicia um container parado, o comando `docker container stop` para um container que esteja em execução.

Utilize a sequencia de teclas **_\<CTRL\> + \<P\> + \<Q\>_** para se desconectar do container sem que ele seja parado. Este comando é chamado de _Read escape sequence_.

```bash
<CTRL> + <P> + <Q>
```

[Docker-install](imagens/docker47.png)

_Note que agora o container ainda está com estatus **Up** o que significa que está em execução._

Para verificar os logs do container utilizamos o comando `docker container logs`.

```bash
vant@node01:~$ docker container logs debian1
root@c1:/# docke container log debian1
bash: docke: command not found
root@c1:/# docker container log debian1
bash: docker: command not found
root@c1:/# exit
exit
```

Pare e remova o container, após isto verifique os containers existentes

```bash
docker container stop debian1
docker container rm debian1
docker container ls -a
```

[Docker-install](imagens/docker48.png)

> **Noata:** Podemos utilizar o parâmetro `-f` no comando `docker container rm` para que o container seja removido mesmo que esteja sendo executado_.

Execute um novo container

[Docker-install](imagens/docker49.png)

Crie um arquivo de teste na pasta atual para enviar ao container c1.

```bash
vagrant@node01:~$ echo "Arquivo de teste docker" > /tmp/arquivo.txt
vagrant@node01:~$ docker container cp /tmp/arquivo.txt c1:tmp
Successfully copied 2.05kB to c1:tmp
```

[Docker-install](imagens/docker50.png)

_O comando **docker container cp** copia um arquivo da maquina host para o container ou vice-versa._

Verifique se o arquivo existe dentro do container através do comando **exec**

[Docker-install](imagens/docker51.png)


```bash
vagrant@node01:~$ docker container exec c1 ls -l /tmp
total 4
-rw-rw-r-- 1 1000 1000 24 Mar 24 12:57 arquivo.txt
vagrant@node01:~$ docker container exec c1 cat /tmp/arquivo
Arquivo de teste docker
```

_O comando **docker container exec** executa um comando no container e envia o retorno na saída padrão(STDOUT) da máquina, caso o container não tenha sido iniciado com a opção **-i** o retorno não será mostrado no STDOUT_

Remova o container criado anteriormente

[Docker-install](imagens/docker52.png)
 
### script para criar containers

```bash
for i in $(seq 1 10)
> do  
> docker conatainer run -it hello-word
> done
```
> Ou escrever o codigo em apenas uma linha: `for i in $(seq 1 10); do docker container run -it hello-world; done`.

[Docker-install](imagens/docker53.png)

**Explicação**

- **for i in $(seq 1 10)** - cria um loop de 1 a 10
- **i** - variável que recebe cada valor
- **do ... done** - bloco de execução
- **docker container run** - comando correto 
- **hello-world** - nome da imagem 

Podemos listar todos `ID`.

[Docker-install](imagens/docker54.png)


```bash
vagrant@node01:~$ docker container ls -aq
f2bf59d9cdf9
8ac102884338
c35b521b4c45
7f77c81c3cc8
26dbf0eb8321
c861ac1bb753
ecf584884a4b
1d9c126940a2
729d9b9f0e8f
4286159e615c
```

### Apagar todos os containers de uma vez

[Docker-install](imagens/docker55.png)

## Conclusão

Esse material vai abordar o conteúdo official do docker, e com exemplos práticos criado ao longo do nosso estudo.

### Resumindo a terminologia do Docker

**Contêiner:** ambiente isolado e leve que pode ter seus próprios processadores, interfaces de rede, etc., mas compartilham o mesmo kernel do sistema operacional. Criado a partir de uma versão de imagem específica.
**Imagem:** uma imagem é basicamente um pacote executável que possui tudo o que é necessário para executar aplicativos, o que inclui um arquivo de configuração, variáveis ​​de ambiente, tempo de execução e bibliotecas.
**Dockerfile:** contém todas as instruções para criar uma imagem do Docker. É basicamente um arquivo de texto simples com instruções para construir uma imagem. Você também pode se referir a isso como a automação da criação de imagens do Docker.
**Tag:** versão de uma imagem. Cada imagem terá uma tag.
**Docker Hub:** repositório de imagens onde podemos encontrar diferentes tipos de imagens.
**Docker Engine:** o sistema que permite criar e executar contêineres do Docker.
**Docker Registry:** o registro do Docker é uma solução que armazena suas imagens do Docker. Este serviço é responsável por hospedar e distribuir as imagens. O registro padrão é o Docker Hub.
**Docker CLI:** interface de linha de comando (CLI) que permite à pessoa executar ações interagindo com Docker. Docker é executado em uma arquitetura cliente-servidor, o que significa que clientes Docker podem se conectar a hosts do Docker localmente ou remotamente. Tanto cliente quanto host do Docker (Daemon) podem ser executados no mesmo host, ou podem ser executados em hosts diferentes e se comunicar por meio de soquetes ou de uma API RESTful.

1. docker container rm $(docker container ls -aq) --> Apaga e mostra todos os containers.
2. docker container ls -aq | xargs docker conatiner rm --> Recebe a entrada e apaga
3. docker container rm $(docker container ls -aq) -------> Apaga todos de uma vez.

### Conteúdo Official

- Docker-DCA 01 - Instalação e Fundamentos
- Docker-DCA 02 - Comandos Docker e Imagens
- Docker-DCA 03 - Docker Images - Melhores Práticas e Multistage Build
- Docker-DCA 04 - Volumes
- Docker-DCA 05 - Volume Plugins
- Docker-DCA 06 - Networking
- Docker-DCA 07 - Compose (docker-compose)
- Docker-DCA 08 - Raft Consensus & Docker Swarm
- Docker-DCA 09 - Docker Swarm - Registry, Services e Tasks
- Docker-DCA 10 - Docker Swarm - Stacks
- Docker-DCA 11 - Monitoramento (Prometheus + Node Exporter + Grafana + Cadvisor)
- Docker-DCA 12 - Tools (PwD, Swarmpit, Portainer, Harbor e Docker Machine)
- Docker-DCA 13 - Kubernetes

**Bons estudos!**

### Jogo no docker - Supermário

`docker container run -it -p 8080:8080 pengbai/docker-supermario`

### Desligando as maquinas

[Docker-install](imagens/docker56.png)
