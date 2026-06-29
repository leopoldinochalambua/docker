# Capítulo 02 - Imagens

## Introduçao

Se os **containers** são processos vivos e dinâmicos em execução no nosso servidor, as imagens **Docker** são o DNA, a receita e o alicerce imutável de todo este ecossistema. Compreender o funcionamento interno das imagens é a chave fundamental para perceber por que razão o Docker é uma tecnologia tão rápida, eficiente e consistente.

Ao contrário das pesadas imagens de discos utilizadas pelas Máquinas Virtuais tradicionais, uma imagem Docker não contém um sistema operativo completo e isolado com o seu próprio kernel. _Em vez disso, ela é um pacote executável, leve e autónomo, que reúne exclusivamente os binários, as bibliotecas, as variáveis de ambiente e os ficheiros de configuração necessários para que a sua aplicação funcione de forma idêntica em qualquer computador do mundo_.

## A Natureza Imutável das Imagens

Uma das características mais importantes que precisa de fixar para a sua jornada de engenharia e certificação é a **imutabilidade**.

> Uma vez construída (build), uma imagem Docker nunca mais muda. Se precisar de atualizar uma linha de código da sua aplicação ou instalar um novo pacote de segurança, o fluxo correto não é modificar a imagem existente, mas sim gerar uma nova versão da imagem (uma nova tag). É esta imutabilidade que elimina em definitivo o risco de desconfiguração de ambientes e garante que o código testado em laboratório se comportará exatamente da mesma forma quando for implementado em produção.

## O que é um Docker Registry?

Um **Docker Registry** é um sistema centralizado de armazenamento e distribuição de imagens. Pense nele como uma grande biblioteca digital onde pode descarregar imagens oficiais validadas, encontrar soluções prontas partilhadas pela comunidade ou alojar e gerir as suas próprias criações.

**Os registos dividem-se fundamentalmente em duas categorias:**

- **Docker Hub:** É o registo público predefinido do motor Docker e a maior biblioteca de imagens de container do mundo. Sempre que executa um comando `docker image pull` sem especificar um endereço de servidor, o Docker recorre automaticamente ao **Docker Hub**.
- **Registos Privados / Corporativos:** No mundo profissional, as empresas evitam expor as suas propriedades intelectuais publicamente. Para armazenar e distribuir imagens de aplicações proprietárias com total segurança e controlo de acessos, utilizam registos privados locais ou soluções de nuvem geridas, tais como:
	- Amazon ECR (Elastic Container Registry)
	- Google Artifact Registry (o sucessor do GCR)
	- Azure Container Registry (ACR)
	- Harbor (uma solução de código aberto muito popular em infraestruturas locais/on-premises)
	- Repositórios privados integrados no próprio Docker Hub Pro/Business

![Dockerhub](resources/02dockerhub.png)

**Serviços Fornecidos pelo Dockerhub**:

- **Alojamento de Imagens Docker:** Repositórios públicos ilimitados gratuitos e suporte para repositórios privados.
- **Autenticação e Gestão de Utilizadores:** Controlo de acessos, organizações e equipas.
- **Construções Automatizadas:** Automatização do processo de construção de imagens através de gatilhos (triggers / webhooks).
- **Integração CI/CD Nativa:** Ligação direta com plataformas como o `GitHub` e o `Bitbucket` para iniciar builds automáticos a cada commit.

### Conta no Dockerhub

Aceda ao endereço [oficial](hub.docker.com) e clique em **Sign Up** para iniciar o registo.

![Registro](resources/02dockerhub1.png)

Preencha o formulário com os seus dados (Docker ID, e-mail e palavra-passe) e clique em **Continue**.

Confirme a ativação da conta através do fluxo enviado para o seu e-mail de registo e, de seguida, efetue a autenticação na plataforma utilizando o botão **Sign In**.

![login](resources/02dockerhub2.png)

Para podermos enviar as nossas próprias imagens personalizadas para o Docker Hub, precisamos de autenticar o cliente Docker do nosso terminal.

Execute o comando `docker login`, especificando o seu nome de utilizador criado:


```bash
docker login -u <usuario_dockerhub>
```

Assim que a autenticação é bem-sucedida, o Docker cria um token codificado localmente. Pode verificar a existência e a estrutura deste ficheiro de autorização executando: `cat ~/.docker/config.json`

O output esperado será um objeto JSON semelhante a este:

```bash
cat ~/.docker/config.json
```

Para remover as credenciais locais da máquina hospedeira e encerrar de forma segura o acesso ao Docker Hub a partir desse terminal, execute o comando de saída:

```bash
docker logout
```

> Em ambientes corporativos ou exames de certificação, evite digitar a palavra-passe diretamente na consola. A boa prática recomenda a utilização de um **Access Token (PAT)** gerado no portal do Docker Hub, ou o envio da senha através da entrada padrão para evitar que fique registada no histórico do Bash: 

`cat meu_token.txt | docker login -u utilizador --password-stdin`

## Docker Image

Uma imagem Docker é um pacote de software leve, autónomo e executável que inclui tudo o que é estritamente necessário para executar uma aplicação: o código fonte, o ambiente de execução (runtime), as ferramentas do sistema, as bibliotecas e as configurações predefinidas.

Ao analisar a anatomia de uma imagem, deve ter em conta dois fatores cruciais:

- **Especificidade de Plataforma**: As imagens Docker são específicas tanto do sistema operativo (SO) como da arquitetura da CPU (como amd64, arm64/v8, etc.) para as quais foram construídas. Não é possível executar nativamente uma imagem construída para a arquitetura clássica da Intel/AMD num servidor com processador ARM sem emulação.
- **Composição Modular**: Uma imagem Docker não é um ficheiro único, grande e monolítico (como um ficheiro `.iso` ou `.zip`). Ela é construída de forma modular através de uma série de camadas sobrepostas e armazenada de forma eficiente num registo.

## Arquitetura de Camadas - Layers

Uma imagem é composta por uma pilha de camadas sobrepostas de leitura única (Read-Only). Cada instrução válida que escrevemos num Dockerfile (tais como FROM, COPY ou RUN) gera uma nova camada imutável sobre a anterior.

```bash
[ Camada 3: RUN apt install -y curl ]  -> Read-Only
[ Camada 2: COPY . /app             ]  -> Read-Only
[ Camada 1: FROM ubuntu:22.04       ]  -> Camada Base (Read-Only)
```

Esta arquitetura traz duas vantagens revolucionárias para a infraestrutura:

- **Eficiência Extrema**: Quando altera uma instrução no seu Dockerfile e executa uma nova construção, o Docker é inteligente: ele reutiliza a cache de todas as camadas anteriores que não sofreram alterações e apenas recompila a camada modificada e as que se seguem. Isto torna o processo de desenvolvimento e compilação incrivelmente rápido.
- **Partilha de Recursos**: Se descarregar dez aplicações diferentes no seu servidor, mas todas elas utilizarem a instrução inicial FROM `ubuntu:22.04`, essa camada base do Ubuntu é descarregada e armazenada apenas uma vez no disco rígido do servidor hospedeiro. Todas as dez imagens partilham a mesma base, economizando gigabytes de espaço de armazenamento.

## A Camada Base 

Esta é a fundação de toda a estrutura da sua imagem, sendo obrigatoriamente especificada pela primeira instrução do Dockerfile: o comando FROM. Dependendo da estratégia do projeto, a camada base pode ser:

- **Um Sistema Operativo Mínimo**: Como o `ubuntu:22.04` ou o `alpine` (uma distribuição Linux ultra-leve com apenas cerca de 5 MB).
- **Um Ambiente de Execução Oficial**: Como o `python:3.9-slim`, `node:20-alpine` ou `openjdk:17`, que já trazem o Linux e as linguagens configuradas pelas equipas oficiais.
- **Uma Aplicação Pronta**: Como o `nginx` ou `postgres`, ideal para quando só precisamos de injetar ficheiros de configuração ou código sobre um serviço já existente.

![Docker Image](resources/02imagem.png)

A principal diferença estrutural entre um **container** e uma **imagem** resume-se à camada superior de leitura e escrita (Read-Write Layer). Enquanto todas as camadas da imagem são estáticas e de leitura única (Read-Only), o Docker adiciona uma fina camada dinâmica no topo assim que o container é iniciado.

Qualquer ação realizada dentro do container em execução — como criar um novo ficheiro, instalar um utilitário de diagnóstico ou modificar uma configuração — é armazenada única e exclusivamente nesta camada superior gravável.

- **Persistência Efémera**: Se o conatiner for eliminado, a sua camada gravável superior é completamente destruída e os dados gerados ali perdem-se.
- **Preservação da Base**: A imagem subjacente permanece rigorosamente intacta e inalterada no disco do servidor, pronta para gerar novos containers limpos a qualquer momento.

![Docker Images e Containers](resources/02containers.png)

Para compreender o impacto financeiro e técnico desta arquitetura no armazenamento de um Data Center, analisemos o seguinte cenário prático:

Imagine que descarregou a imagem oficial ubuntu:18.04, que pesa exatamente 200 MB no disco.

Cenário com 1 Container: Se iniciar um container a partir desta imagem e ele gerar 50 MB de dados específicos (logs, ficheiros temporários, código) na sua camada gravável, o espaço total consumido no servidor será de:

`200 MB (Imagem Base) + 50 MB (container 1) = 250 MB`

Cenário com 10 containers Simultâneos: Se instanciar 10 containers idênticos a partir dessa mesmíssima imagem, e cada um deles gerar os seus próprios 50 MB de dados isolados, a magia da partilha de camadas atua. O Docker não duplica os 200 MB da imagem base. Todos os 10 containers partilham a mesma base imutável de forma síncrona. O cálculo do espaço total consumido será:

`200 MB (Imagem Base Partilhada) + (10 x 50 MB das camadas indi`

> Se tentasse replicar exatamente o mesmo cenário de 10 ambientes isolados utilizando Máquinas Virtuais (VMs) tradicionais, o consumo de recursos seria exponencialmente superior. Como cada VM exige a instalação independente de todo o sistema operativo, dos drivers e da alocação rígida de disco virtuais, o mesmo laboratório consumiria facilmente entre 20 GB a 40 GB de armazenamento, além do desperdício severo de memória RAM e processamento (CPU).

## Principais Comandos de Gestão de Imagens 

A categoria de objetos docker image agrupa todos os subcomandos necessários para auditar, modificar, empacotar e limpar imagens no repositório local do servidor.

A tabela abaixo resume as instruções estruturais que serão estudadas na prática:

| **Comando**            | **Descrição Técnica**                                                                                                                         |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `docker image build`   | Constrói uma nova imagem personalizada a partir das instruções escritas num ficheiro Dockerfile.                                              |
| `docker image history` | Exibe o histórico de criação da imagem, listando todas as camadas de leitura única (*layers*) e o tamanho de cada uma.                        |
| `docker image inspect` | Apresenta uma estrutura detalhada em formato JSON com os metadados da imagem (arquitetura, variáveis de ambiente, autor, entre outros).       |
| `docker image prune`   | Remove do armazenamento local todas as imagens pendentes ou não utilizadas (*dangling images*) que não estejam associadas a nenhum contentor. |
| `docker image save`    | Exporta uma imagem Docker local para um ficheiro em formato `.tar`, ideal para migrações ou ambientes sem acesso à Internet (*air-gapped*).   |
| `docker image tag`     | Cria uma nova etiqueta (*tag*) para uma imagem existente, permitindo associá-la a outro repositório, versão ou utilizador.                    |

## Gerenciar Imagens no Docker

Vamos avançar para a vertente prática de auditoria, exportação e criação de imagens através do terminal.

Para essa sessão vamos usar a maquina node02.

1. **Listar e Auditar as Camadas de uma Imagem**

Primeiro, liste as imagens locais e verifique o histórico de instruções e comandos que foram utilizados originalmente para construir a imagem do Debian:

```bash
docker image ls
docker image history debian
```

> O comando `docker image history` exibe detalhadamente cada uma das camadas de leitura única (layers) que compõem a imagem, revelando o tamanho em disco que cada instrução adicionou ao pacote final.

Para extrair todos os metadados estruturais de uma imagem em formato JSON (como variáveis de ambiente, portas expostas, volumes e comandos padrão), utilizamos o subcomando `inspect`:

```bash
docker image inspect debian
```
_O comando **docker image inspect** exibe informações detalhadas de uma imagem_

2. **Criar uma Imagem a partir de um container**

Vamos simular a criação de uma imagem personalizada a partir de um cenário real: alterando um contentor ativo. Primeiro, instanciamos o contentor e instalamos o servidor web Nginx no seu interior:

**Cria e inicia o contentor Debian**

`docker container run -dit --name servidor-debian debian`

**Atualiza os repositórios internos do contentor**

`docker container exec servidor-debian apt-get update`

**Instala o servidor Nginx dentro do contentor**

`docker container exec servidor-debian apt-get install nginx -y`

Para registar o estado atual deste container e transformá-lo numa nova imagem estática, utilizamos o subcomando `commit`:

`docker container commit servidor-debian webserver-nginx`

**Valide se a nova imagem foi criada localmente**

`docker image ls`

O comando `docker container commit` cria uma imagem a partir de alterações manuais num container vivo. Embora útil para auditorias de emergência, este procedimento não é o recomendado para o dia a dia em produção, uma vez que gera imagens sem rastreabilidade e difíceis de auditar. Mais à frente aprenderá a fazer isto da forma correta e automatizada utilizando um ficheiro `Dockerfile`.

3. **Exportar e Importar Imagens via Ficheiros .tar (save e load)**

Caso necessite de mover uma imagem para um servidor que não tem acesso à internet (ambiente air-gapped), pode exportá-la para um ficheiro compactado utilizando a opção save:

**Exporta a imagem para um ficheiro tar, de seguida verifiva o tamanho do ficheiro gerado no disco**

`docker image save webserver-nginx -o imagem-webserver-nginx.tar`

`du -sh imagem-webserver-nginx.tar`

Para demonstrar a eficácia do processo, vamos simular uma limpeza completa, removendo o container de origem e a imagem que acabámos de criar:

**Remove o contentor de forma forçada**

`docker container rm -f servidor-debian`

**Remove a imagem local**

`docker image rm webserver-nginx`

**Valide que a imagem desapareceu do sistema**

`docker image ls`

Agora, para restaurar a imagem a partir do ficheiro guardado em disco, utilizamos o subcomando load:

```bash
# Importa a imagem de volta para o Docker Engine
docker image load -i imagem-webserver-nginx.tar

# Valide se a imagem está novamente disponível
docker image ls
```

4. **Validar o Funcionamento e Limpeza Total**

Para garantir que a imagem importada mantém todas as modificações (incluindo o Nginx instalado), instancie um novo contentor a partir dela:

```bash
docker container run -dit --name webserver webserver-nginx
docker container ls
```

Por fim, utilize o bloco de substituição de comandos para purgar o ambiente de laboratório, removendo todos os contentores existentes de uma só vez:

```bash
docker container rm -f $(docker container ls -aq)
# Valide que o ambiente está limpo
docker container ls
```

> O comando docker container ls -aq é executado dentro de uma subshell $(...). Ele gera uma lista contendo única e exclusivamente os IDs hexadecimais de todos os contentores do sistema. Essa lista é injetada diretamente como argumento no docker container rm -f, forçando a eliminação em massa imediata.

## Dockerfile

O **Dockerfile** é um ficheiro de texto simples que funciona como o guião ou receita de instruções detalhadas para a criação automatizada duma imagem Docker personalizada. Através deste ficheiro, o motor Docker consegue ler as diretivas sequencialmente e compilar a imagem através do comando docker image build.

![Dockerfile](resources/02dockerfile.png)

## Sintaxe e Instruções Principais

Embora o interpretador do Dockerfile não seja sensível a maiúsculas e minúsculas (case-insensitive), por convenção e boa prática de mercado, escrevemos sempre as instruções em maiúsculas para destacar os comandos dos seus respetivos argumentos, tornando a leitura mais clara.

> Por padrão, o ficheiro deve chamar-se estritamente Dockerfile (com a letra inicial D em maiúscula e sem qualquer extensão de ficheiro, como .txt).

O Docker executa as instruções contidas no ficheiro rigorosamente de cima para baixo (Top-down). A tabela abaixo resume a estrutura básica da sintaxe:

| **Instrução** | **Função**                                                                                | **Exemplo**                                     |
| ------------- | ----------------------------------------------------------------------------------------- | ----------------------------------------------- |
| `FROM`        | Define a imagem base utilizada na construção da nova imagem.                              | `FROM ubuntu:22.04`                             |
| `COPY`        | Copia ficheiros ou diretórios do sistema anfitrião para o sistema de ficheiros da imagem. | `COPY app.py /app/`                             |
| `RUN`         | Executa comandos durante o processo de construção da imagem.                              | `RUN apt-get update && apt-get install -y curl` |
| `EXPOSE`      | Documenta a porta utilizada pela aplicação no interior do contentor.                      | `EXPOSE 80/tcp`                                 |
| `CMD`         | Define o comando padrão executado quando um contentor é iniciado a partir da imagem.      | `CMD ["python", "app.py"]`                      |

> Qualquer linha iniciada pelo carácter # é tratada como um comentário e ignorada pelo processo de construção. Contudo, se o # for inserido no meio de uma linha, ele será interpretado como um argumento normal do comando em execução.

O arquivo de Dockerfile não é case-sensitive, no entanto por convenção utilizamos os parâmetros em maiúsculo para que sua leitura seja mais agradável e de fácil compreensão. O nome do arquivo deve se chamar **Dockerfile** apenas com a letra inicial **D** em maiúsculo.

## Definições Detalhadas das Diretivas 

Para dominar a governança de imagens, é vital compreender o comportamento exato de cada diretiva no sistema de camadas:

- **FROM**: Inicializa um novo estágio de compilação (build stage) e define a Imagem Pai obrigatória para as instruções subsequentes. Qualquer Dockerfile válido tem de começar com esta instrução.
- **COPY**: Copia ficheiros ou diretórios da máquina hospedeira (origem local) e adiciona-os ao sistema de ficheiros da imagem do contentor (destino).
- **ADD**: Semelhante ao COPY, mas possui superpoderes adicionais: permite que a origem seja uma URL remota (faz o download do ficheiro durante o build) e descompacta automaticamente ficheiros de arquivo locais em formatos reconhecidos (como .tar.gz).
- **RUN**: Executa comandos dentro do ambiente de compilação, criando uma nova camada imutável no topo da imagem atual.

> Deve combinar múltiplos comandos Linux utilizando os operadores ; ou && e a barra invertida \ para quebra de linha. Isto agrupa as instruções num único bloco RUN, gerando apenas uma camada na imagem, o que reduz drasticamente o tamanho final do pacote.

- **EXPOSE**: Funciona como documentação metadata. Informa o Docker (e o utilizador) sobre a porta em que o contentor estará a escutar o tráfego em tempo de execução. Pode especificar portas TCP ou UDP (ex: EXPOSE 53/udp). Se omitido, o padrão TCP é assumido.
- **CMD**: Define o comando padrão que será executado assim que o contentor for iniciado. Só pode existir uma única instrução CMD ativa no Dockerfile (se colocar várias, apenas a última será executada). O CMD pode ser facilmente substituído se o utilizador passar um comando diferente no final do docker run.
- **ENTRYPOINT**: Permite configurar o contentor para funcionar como se fosse um executável binário fixo do sistema operacional. Ao contrário do CMD, o comando definido no ENTRYPOINT não é ignorado quando o utilizador passa argumentos no docker run; em vez disso, esses argumentos externos são anexados como parâmetros ao próprio ENTRYPOINT.

> **ENTRYPOINT + CMD**: Uma arquitetura avançada muito comum utiliza o ENTRYPOINT para definir o executável principal (ex: ENTRYPOINT ["nginx"]) e o CMD para fornecer os parâmetros padrão que podem ser alterados pelo utilizador (ex: CMD ["-g", "daemon off;"]).
**Definições**

### Laboratório 1: O Contentor de Eco | Crianção do dockerfile

Vamos criar uma pasta dedicada para organizar os nossos ficheiros de configuração e estruturar o nosso primeiro Dockerfile. Este exercício servirá para compreender, na prática, como o CMD atua como um argumento dinâmico do ENTRYPOINT.

```bash
# Cria a pasta e entra nela
mkdir -p ~/dockerfiles/echo-container
cd ~/dockerfiles/echo-container

# Cria e edita o Dockerfile
vim Dockerfile
```
Insira o seguinte conteúdo no ficheiro:

```dockerfile
FROM         alpine
ENTRYPOINT   ["echo"]
CMD          ["--help"]
```

Para compilar o ficheiro e gerar a imagem estruturada, utilizamos o comando `docker image build`:

```bash
docker image build -t echo-container .
docker image ls
```

A opção -t especifica a Tag (o nome amigável da imagem).

_O ponto final . é o Contexto de Compilação (Build Context). Ele indica ao Docker Engine que o ficheiro Dockerfile e todos os ficheiros que ele precise de copiar estão localizados na pasta atual (PWD). Nunca se esqueça de incluir o ponto no final_.

Valide se a imagem foi registada com sucesso no seu repositório local:

```bash
docker image ls
```

Se executarmos o container sem passar nenhum argumento adicional, ele irá recorrer ao valor padrão definido no CMD (--help):

```bash
docker container run --rm -it echo-container
```

A opção --rm é uma excelente prática de laboratório. Ela garante que o contaier será automaticamente eliminado do sistema assim que terminar a sua execução, evitando a acumulação de lixo digital no disco rígido.

Agora, execute o mesmo container, mas adicione uma frase personalizada no final do comando:

```bash
docker container run --rm -it echo-container Olá Mundo, aprendendo Docker com conteúdo DCA!
```

Ao passar argumentos após o nome da imagem, o utilizador substituiu o CMD original (--help) pela nova frase. Como o ENTRYPOINT está definido como ["echo"], o Docker executou internamente o comando unificado: echo Olá Mundo, aprendendo Docker com conteúdo DCA!.

> Ao passar argumentos após o nome da imagem, o utilizador substituiu o CMD original (--help) pela nova frase. Como o ENTRYPOINT está definido como ["echo"], o Docker executou internamente o comando unificado: echo Olá Mundo, aprendendo Docker com conteúdo DCA!.

### Laboratório 2: Criar um Servidor Web Apache

Vamos elevar o nível e criar uma imagem personalizada que transforma um Ccontainer minimalista do Debian num servidor web Apache totalmente funcional.

```bash
# Cria uma nova pasta para o servidor web e acede à mesma
mkdir -p ~/dockerfiles/webserver
cd ~/dockerfiles/webserver

# Cria o Dockerfile
vim Dockerfile
```

Insira a seguinte estrutura de instruções:

```bash
FROM    debian
RUN     apt-get update && \
        apt-get install wget git apache2 -yq
EXPOSE  80          
CMD     ["apachectl", "-D", "FOREGROUND"]
```

Repare que agrupámos o apt-get update e o apt-get install na mesma instrução RUN utilizando o operador lógico &&. Isto garante que o Docker cria apenas uma única camada para o processo de instalação do software, reduzindo drasticamente o tamanho final da imagem.

Por padrão, o Apache tenta correr como um serviço de fundo (daemon). Num contentor Docker, se o processo principal (PID 1) passar para segundo plano, o contentor morre imediatamente. O argumento "-D", "FOREGROUND" força o Apache a correr em primeiro plano, mantendo o nosso contentor ativo indefinidamente.

Execute o comando de construção na pasta onde guardou o novo ficheiro:

```bash
docker image build -t webserver .
```

Acompanhe o terminal a descarregar as dependências e a compilar as camadas. No final, valide se a imagem está pronta a ser utilizada:

```bash
docker image ls
```

## Validar e Aceder à Aplicação

Depois de instanciar o seu contentor com o mapeamento de portas ativo (por exemplo, -p 8080:80), abra o seu navegador de internet (browser) e tente aceder à aplicação através do endereço IP da máquina hospedeira (host) acompanhado da porta exposta. Isto servirá para validar se o servidor interno foi executado com total sucesso.

A captura de ecrã seguinte ilustra o acesso bem-sucedido à aplicação em produção:



## Comandos Avançados de Imagens

Para complementar o seu laboratório diário, consulte abaixo a sintaxe correta dos comandos mais utilizados para auditoria e manutenção do repositório local:

1. Listar Imagens Docker

Para listar todas as imagens armazenadas na sua máquina, pode utilizar a sintaxe clássica ou a moderna orientada a objetos:

```Bash
docker image ls
```
Ou a sintaxe clássica equivalente:

`docker images`

2. Transferir uma Imagem de um Registo

Para descarregar uma imagem oficial ou comunitária diretamente do Docker Hub para o seu servidor sem precisar de iniciar um contentor de imediato, utilize o comando pull:

Bash
docker image pull <nome-da-imagem>
# Exemplo prático:
docker image pull python:3.10-slim

3. Filtrar a Listagem de Imagens

Quando o seu servidor tem centenas de imagens e precisa de localizar um componente específico de forma ágil, utilize a flag -f (filter) combinada com um critério de referência:

Bash
docker image ls -f "reference=webserver"
⚠️ Atenção ao Terminal: Certifique-se sempre de que utiliza aspas retas padrão (") no seu terminal. A utilização de aspas tipográficas ou curvas (“) resultará num erro de sintaxe no Bash.

4. Pesquisar Imagens no Docker Hub via CLI

Se quiser validar se uma imagem existe ou verificar a sua popularidade (número de estrelas) sem sair do terminal, utilize o comando search:

docker search ubuntu

5. Remover uma Imagem do Repositório Local

Para eliminar uma imagem do seu disco rígido local, utilize o ID ou o nome da imagem. Lembre-se de que a imagem não pode estar a ser utilizada por nenhum contentor (mesmo que este esteja parado).

docker image rm <id-da-imagem>

# Ou a sintaxe clássica equivalente:

docker rmi <id-da-imagem>

6. Limpeza Automatizada (Prune)

Com o passar do tempo, as construções sucessivas de Dockerfiles deixam imagens órfãs ou pendentes (dangling images — aquelas que aparecem listadas com o nome <none>). Para libertar espaço em disco removendo todas as imagens não utilizadas que não estejam associadas a nenhum contentor ativo ou parado, execute:


docker image prune

💡 Dica de Limpeza Profunda: O comando acima remove apenas as imagens sem nome (<none>). Se quiser fazer uma purga total e apagar absolutamente todas as imagens locais que não tenham nenhum contentor associado no momento, adicione a flag -a (All): docker image prune -a.

## Enviando a imagem para o Dockerhub

Publicar Imagens no Docker Hub

A publicação de imagens num registo remoto garante a portabilidade do seu software. Ao enviar as suas imagens personalizadas para o Docker Hub, qualquer servidor ou membro da sua equipa poderá descarregá-las e utilizá-las instantaneamente com o comando docker image pull.

O fluxo padrão para publicar uma imagem assenta estritamente em três passos sequenciais:

`[ 1. docker login ] -> [ 2. docker image tag ] -> [ 3. docker image push ]`


**Passo 1: Criar o Repositório no Painel do Docker Hub**

Antes de empurrar a sua imagem via linha de comandos, necessita de ter um espaço reservado para ela na interface web do Docker Hub.

- Aceda ao portal hub.docker.com, inicie sessão e clique no separador Repositories na barra de navegação superior.
- Clique no botão Create Repository.
- Defina as configurações do repositório:
	- Name: Introduza o nome do repositório (ex: echo-container ou webserver).
	- Visibility: Escolha entre Public (qualquer pessoa no mundo pode descarregar a imagem) ou Private (apenas o utilizador e contas autorizadas têm acesso).
- Clique em Create.

**Passo 2: Autenticação no Terminal (docker login)**

Para que o Docker Engine local saiba que tem permissões para enviar ficheiros para a sua conta remota, efetue a autenticação no terminal:

```bash
docker login -u <usuario_dockerhub>
```

> O sistema irá solicitar a sua palavra-passe ou o seu Personal Access Token (PAT). Por motivos de segurança, os caracteres não serão exibidos no ecrã.

Passo 3: Atribuir a Tag Padrão do Registo (docker image tag)

O motor Docker local não sabe para onde enviar uma imagem baseando-se apenas no seu nome curto local (webserver). Para direcionar o upload para o destino correto, a imagem local tem obrigatoriamente de ser renomeada seguindo a estrutura padrão de nomenclatura dos registos:

`nome\_de\_utilizador\_dockerhub/nome_do_repositório:tag`

Vamos aplicar este conceito prático às duas imagens que construímos nos laboratórios anteriores (echo-container e webserver):

```bash
# Formato completo especificando a tag explicitamente
docker image tag echo-container <seu_utilizador_dockerhub>/echo-container:1.0

# Formato omitindo a tag (o Docker assume automaticamente a tag "latest")
docker image tag webserver <seu_utilizador_dockerhub>/webserver
```

Se listar as suas imagens agora com `docker image ls`, verá que foram criados atalhos com os nomes completos prontos para o upload.

_Caso não seja informada uma versão, o docker entende que a versão trata-se da **latest**_


**Passo 4: Enviar as Imagens (docker image push)**

Com as imagens devidamente etiquetadas com o seu nome de utilizador, execute o comando de envio para iniciar a transferência das camadas para a nuvem:


```bash
# Envia a versão estável específica
docker image push <seu_utilizador_dockerhub>/echo-container:1.0

# Envia a versão padrão (latest)
docker image push <seu_utilizador_dockerhub>/webserver
```

O terminal exibirá o progresso do upload de cada camada (layer). Se uma camada já existir no Docker Hub (por ser partilhada com uma imagem oficial), o Docker exibirá a mensagem Layer already exists e saltará a transferência, economizando tempo e largura de banda.

## Enviar Múltiplas Tags em Massa (--all-tags)

No desenvolvimento contínuo de software, é comum atribuir várias etiquetas à mesma imagem (ex: marcar a mesma imagem idêntica como v1, 1.0.4 e latest para dar flexibilidade de reversão aos utilizadores).

Para evitar ter de executar o comando docker image push individualmente para cada versão, pode utilizar a flag -a (ou --all-tags):

```bash
# Exemplo de etiquetagem de várias versões para o mesmo repositório
docker image tag webserver <seu_utilizador_dockerhub>/webserver:v1
docker image tag webserver <seu_utilizador_dockerhub>/webserver:1.0.0
docker image tag webserver <seu_utilizador_dockerhub>/webserver:latest

# Envia TODAS as tags deste repositório de uma só vez
docker image push -a <seu_utilizador_dockerhub>/webserver
```

**Passo 5: Terminar a Sessão por Segurança (docker logout)**

Assim que validar no painel web do Docker Hub que as suas imagens foram carregadas com sucesso, limpe as suas credenciais locais do ficheiro config.json do terminal da máquina executando:

```bash
docker logout
```

**Passo 6: Validar e Descarregar do Zero**

Para testar o isolamento e garantir que o seu repositório público está perfeitamente funcional, limpe todo o seu ambiente local e descarregue a imagem diretamente da nuvem, como faria qualquer outro utilizador:

```bash
# Remove de forma forçada todas as imagens locais do seu ambiente
docker image rm -f $(docker image ls -aq)

# Transfere a sua imagem diretamente do Docker Hub público
docker image pull <seu_utilizador_dockerhub>/webserver

# Instancia o contentor em segundo plano a partir da imagem remota
docker container run -dit --name meu-servidor-remoto -p 8080:80 <seu_utilizador_dockerhub>/webserver

# Valida se o contentor está ativo no sistema
docker container ls -a
```
Assim que o processo de `push` estiver concluído, as suas imagens passam a estar listadas e visíveis no seu painel web do Docker Hub. A partir desse momento, desde que o seu repositório esteja configurado como Público, qualquer utilizador ou sistema de CI/CD em qualquer parte do mundo poderá descarregar a sua imagem instantaneamente utilizando o comando padrão:

`docker image pull <utilizador_dockerhub>/<nome_do_repositorio>:<versao>`

Esta capacidade de distribuição global, sem necessidade de configurações complexas de rede, é um dos principais fatores que tornam o Docker a ferramenta padrão da cultura DevOps moderna.

![Repositório](resources/02dockerhub3.png)

## Melhores práticas com o Dockerfile 

Ao desenhar uma imagem através de um Dockerfile, a regra de ouro da arquitetura moderna de microsserviços dita que os contentores gerados devem ser tão efémeros quanto possível.

Dizer que um contentor é efémero significa que ele deve ter a capacidade de ser interrompido, destruído ou substituído a qualquer momento, de forma instantânea, exigindo o mínimo absoluto de configuração ou intervenção manual para que uma nova instância equivalente entre em funcionamento.

## O Manifesto Twelve-Factor App (Aplicação dos Doze Fatores)

Uma excelente metodologia estrutural para alcançar este nível de maturidade e portabilidade na nuvem é a The Twelve-Factor App (especialmente relevante para quem desenha pipelines de CI/CD). Na sua secção dedicada aos Processos (Processes), o manifesto estipula que as aplicações modernas devem ser executadas como processos stateless (sem retenção de estado).

### O que é um Processo Stateless? 

Significa que o contentor não deve depender nem guardar dados cruciais ou persistentes no seu próprio sistema de ficheiros local (na sua camada gravável superior). Quaisquer dados que precisem de persistir além do ciclo de vida do contentor — como uploads de utilizadores, logs históricos ou bases de dados — devem obrigatoriamente ser armazenados num serviço de suporte externo (backing service), como um banco de dados gerido, um sistema de ficheiros em rede (NFS) ou volumes partilhados do Docker.

Se o seu contentor for totalmente independente do estado local, o seu orquestrador (como o Docker Swarm ou Kubernetes) pode destruir uma instância com falhas no Nó A e recriá-la imediatamente no Nó B sem qualquer perda de informação ou impacto para o utilizador final. Isto garante alta disponibilidade e resiliência à sua infraestrutura.

Com base neste princípio de efemeridade, siga sempre estas regras básicas na escrita do seu código de infraestrutura:

1. Minimize o Contexto de Compilação (Build Context): Evite executar o comando docker image build na raiz do seu utilizador ou do sistema (ex: docker build . dentro do /home/user). O Docker tentará ler todos os ficheiros da pasta atual. Utilize sempre um diretório limpo e isolado apenas com os ficheiros necessários para o projeto.
2. Utilize o ficheiro .dockerignore: Tal como o .gitignore no Git, crie um ficheiro chamado .dockerignore na pasta do projeto para listar ficheiros e pastas que não devem ser enviados para o motor Docker (ex: .git, node_modules, logs temporários). Isto reduz o tamanho da imagem e acelera o build.
3. Ordene as Instruções com Inteligência (Otimização de Cache): Como o Docker lê o Dockerfile de cima para baixo, coloque as instruções que mudam com menos frequência (como FROM e a instalação de pacotes via RUN apt) no topo do ficheiro. Deixe as linhas que mudam a cada alteração de código (como o COPY dos ficheiros da sua aplicação) o mais abaixo possível. Assim, a cache do Docker será reaproveitada ao máximo, reduzindo o tempo de compilação.

### Compreender o Contexto de Compilação (Build Context)

Quando executamos o comando docker image build, a pasta para a qual apontamos no final da linha (frequentemente o ponto . para referenciar o diretório atual) passa a ser designada como o Contexto de Compilação (Build Context).

Por predefinição, o Docker espera encontrar o ficheiro Dockerfile na raiz dessa pasta, mas podemos especificar uma localização alternativa recorrendo à flag -f. Independentemente de onde o Dockerfile esteja guardado, todo o conteúdo dos ficheiros e subpastas da pasta especificada como contexto é compactado e enviado para o Docker Daemon antes de o processo começar.

> Nunca crie ou execute um Dockerfile diretamente na raiz do seu utilizador (~/ ou /home/user). Caso o faça, todo o conteúdo da sua Home Directory — incluindo gigabytes de ficheiros pessoais, transferências e a cache pesada de navegadores web (~/.cache) — será enviado para o Docker Daemon. Isto resultará num consumo massivo de memória RAM, lentidão extrema e, muito provavelmente, na falha do processo de build.

## Laboratório Prático: Manipular o Contexto

Vamos provar este comportamento na prática. Primeiro, criamos uma estrutura limpa e um ficheiro de texto estático que servirá como o nosso código:

```bash
# Cria a pasta do projeto e acede à mesma
mkdir -p ~/dockerfiles/exemplo1
cd ~/dockerfiles/exemplo1

# Cria um ficheiro de texto com conteúdo estático
echo "Dockerfile Melhores Práticas" > conteudo.txt
``` 

De seguida, crie o ficheiro Dockerfile:

```bash
vim Dockerfile
``` 

```dockerfile
FROM    busybox
COPY    conteudo.txt /
RUN     cat /conteudo.txt
``` 

Construa a primeira versão da imagem (v1) utilizando a pasta atual como contexto (.):


```bash
docker image build -t exemplo:v1 . 
``` 

Agora, vamos simular uma arquitetura de projeto mais complexa, onde o ficheiro Dockerfile fica guardado numa pasta separada dos ficheiros de código da aplicação.

```bash
# Cria duas pastas distintas: uma para a infraestrutura e outra para o código
mkdir -p image context

# Move cada ficheiro para o seu respetivo lugar
mv Dockerfile image/
mv conteudo.txt context/
``` 

Para construir a segunda versão da imagem (v2), precisamos de indicar explicitamente ao Docker onde está o ficheiro (-f) e onde estão os dados (context):

```bash
docker image build --no-cache -t exemplo:v2 -f image/Dockerfile context
```

> `--no-cache`: Ao forçar o parâmetro --no-cache, dizemos ao Docker Engine para ignorar qualquer camada pré-existente e reconstruir tudo do zero. Se listar as imagens agora, notará que a v1 e a v2 possuem o mesmo tamanho, mas IDs totalmente diferentes:


```bash
$ docker image ls 
```

Output esperado:

```bash
REPOSITORY        TAG           IMAGE ID       CREATED          SIZE
exemplo           v2            589078e3e007   2 seconds ago    1.24MB
exemplo           v1            de0bdd45cb9a   3 minutes ago    1.24MB
```

Caso inclua ficheiros desnecessários na pasta de contexto, o tamanho do envio para o Daemon crescerá desnecessariamente. Embora esses ficheiros não entrem na imagem final (a menos que use um COPY .), eles consomem tempo precioso de upload local.

Vamos simular este problema copiando dados pesados de logs do sistema para dentro da nossa pasta context:

```bash
# Copia os logs do sistema (requer privilégios administrativos)
sudo cp -r /var/log/ ~/dockerfiles/exemplo1/context/

# Ajusta as permissões para o utilizador comum (Vagrant) conseguir ler
sudo chown -R vagrant:vagrant ~/dockerfiles/exemplo1/context/log

# Executa o build da versão v3 medindo o impacto
docker image build --no-cache -t exemplo:v3 -f image/Dockerfile context
``` 

Ao analisar as primeiras linhas do output gerado no terminal, a diferença salta à vista imediatamente:

No primeiro build (apenas texto): `Sending build context to Docker daemon  2.607kB`
No build com a pasta de logs infiltrada: `Sending build context to Docker daemon  26.62MB`

Embora a imagem final v3 continue a ter os mesmos 1.24 MB (visto que o Dockerfile apenas copia o ficheiro conteudo.txt e ignora a pasta log), o tempo gasto pelo processador a compactar e a transferir os dados para o motor Docker foi significativamente superior.

Utilizando o utilitário time do Linux para monitorizar a execução, os resultados são claros:

- Contexto Limpo (2.6 KB): Tempo total de 0m0.910s
- Contexto Sobrecarregado (26.62 MB): Tempo total de 0m1.368s

Neste exemplo lidámos com escassos megabytes, pelo que a diferença foi de apenas algumas frações de segundo. Contudo, em aplicações empresariais reais (como projetos Node.js com pastas node_modules gigantescas ou microsserviços Java), o tempo de envio do contexto pode saltar de segundos para vários minutos, atrasando severamente a sua pipeline de CI/CD. Mantenha o contexto sempre limpo!

### Excluir Ficheiros do Build

ara evitar o envio de ficheiros e pastas que não são relevantes para o processo de compilação (como logs, ficheiros de configuração local ou chaves privadas), podemos criar um ficheiro .dockerignore.

O funcionamento deste ficheiro é virtualmente idêntico ao do .gitignore do Git: permite definir padrões de exclusão através de máscaras de texto, garantindo que o motor Docker ignore esses elementos sem que tenhamos de os apagar ou mover do nosso repositório de trabalho.

> Para a referência do Docker Ignore veja a [Documentação Oficial](https://docs.docker.com/engine/reference/builder/#dockerignore-file)

## Laboratório Prático: O .dockerignore

Vamos criar um ficheiro .dockerignore dentro da nossa pasta de contexto para impedir que a pasta pesada de logs (log), que infiltrámos no exercício anterior, continue a sobrecarregar o envio de dados para o Daemon.

O ficheiro .dockerignore deve ser criado obrigatoriamente na raiz do diretório definido como contexto de compilação (neste caso, dentro da pasta context).


```bash
# Cria e edita o ficheiro de exclusão dentro da pasta context
vim context/.dockerignore
``` 

Insira o seguinte padrão de exclusão no ficheiro:

```gitignore
# Comentário: Ignorar a pasta de logs do sistema
log
``` 
Agora, execute novamente a construção de uma nova versão da imagem (v4), mantendo exatamente a mesma estrutura anterior:


```bash
docker image build --no-cache -t exemplo:v4 -f image/Dockerfile context
``` 

Se observar a primeira linha do output do comando, verá que a pasta log foi completamente ignorada pelo cliente Docker:

`Sending build context to Docker daemon  2.712kB`

O tamanho do contexto caiu instantaneamente dos 26.62 MB anteriores para escassos 2.7 KB (ligeiramente maior do que o primeiro build apenas porque agora incluímos o próprio ficheiro .dockerignore no envio). O processo voltou a ser ultra-rápido, poupando CPU e memória.

### Técnicas Avançadas de Otimização de Dockerfiles

Como vimos nos exemplos anteriores, construir imagens funcionais é apenas o primeiro passo. O verdadeiro desafio em ambientes de produção e arquiteturas DevOps é garantir que estas imagens sejam seguras, rápidas de compilar e o mais pequenas possível.

Abaixo, analisamos as 9 diretrizes fundamentais de otimização utilizando o nosso estudo de caso em Java e Go.

#### Dica #1: A ordem importa para o cache

Dica #1: A Ordem das Instruções Importa para a Cache
O motor Docker constrói as imagens utilizando um sistema de cache estrito camada a camada. Quando executa o comando docker image build, o Docker verifica de cima para baixo se a instrução atual e os ficheiros associados sofreram alterações. Se a cache de uma camada for invalidada, todas as instruções subsequentes serão executadas do zero, ignorando a cache.

> Ordene sempre as instruções do seu Dockerfile partindo do que muda menos frequentemente para o que muda mais frequentemente.

![melhores-práticas-1](resources/02melhores-praticas-1.png)

```bash
vim Dockerfile
```

```dockerfile
FROM        debian:9
RUN         apt-get update
RUN         apt-get install -y openjdk-8-jdk wget ssh vim
# O código da aplicação (que muda a cada commit) deve ficar no fim
COPY        app /app
ENTRYPOINT  ["java", "-jar", "/app/target/app.jar"]
``` 

```bash
docker image build -t dicas:v1 .
```

#### Dica #2: Especificar o COPY para Limitar a Invalidação da Cache

Evite copiar pastas genéricas ou usar COPY . se não for estritamente necessário. Sempre que copia ficheiros para a imagem, qualquer alteração mínima num único ficheiro (mesmo que seja apenas um comentário num ficheiro de documentação) quebrará a cache daquela linha em diante.

Ao isolar e copiar apenas os binários finais compilados, alterações no código-fonte não processado não afetarão as camadas de sistema da imagem:

![melhores-práticas-2](resources/02melhores-praticas-2.png)

```bash
vim Dockerfile
```

```dockerfile
FROM        debian:9
RUN         apt-get update
RUN         apt-get install -y openjdk-8-jdk wget ssh vim
# Copia estritamente os ficheiros necessários para a execução
COPY        app/target/app.jar /app/app.jar
COPY        app/samples /samples
ENTRYPOINT  ["java", "-jar", "/app/app.jar"]
``` 

```bash
docker image build -t dicas:v2 .
``` 

#### Dica #3: Identificar e Agrupar Instruções RUN

Cada instrução RUN, COPY e ADD adiciona uma nova camada independente à imagem. Agrupar comandos Linux relacionados utilizando os operadores lógicos && e a barra invertida \ para quebra de linha cria uma única unidade de cache e reduz o número de camadas, otimizando o desempenho do sistema de ficheiros unificado (UnionFS).

![melhores-práticas-3](resources/02melhores-praticas-3.png)

```bash
vim Dockerfile
```

```dockerfile
FROM       debian:9
# Agrupamento de comandos num único passo lógico
RUN        apt-get update \
        && apt-get install -y \
            openjdk-8-jdk wget \
            ssh vim   
COPY        app/target/app.jar /app/app.jar
COPY        app/samples /samples
ENTRYPOINT  ["java", "-jar", "/app/app.jar"]
``` 

```bash
docker image build -t dicas:v3 .
``` 

#### Dica #4: Eliminar Dependências e Pacotes Desnecessários

Para colocar uma aplicação em produção, não precisa de ferramentas de compilação ou de depuração (debug). No caso do Java, podemos substituir o JDK (Java Development Kit, que traz o compilador e ferramentas pesadas) pelo JRE (Java Runtime Environment), que contém apenas o ambiente mínimo de execução.

Adicionalmente, utilize sempre a flag --no-install-recommends no gestor de pacotes apt para impedir a instalação de pacotes sugeridos que não são obrigatórios.


![melhores-práticas-4](resources/02melhores-praticas-4.png)

```bash
vim Dockerfile
```

```dockerfile
FROM        debian:9
RUN         apt-get update \
         && apt-get install -y --no-install-recommends \
            openjdk-8-jre 
COPY        app/target/app.jar /app/app.jar
COPY        app/samples /samples
ENTRYPOINT  ["java", "-jar", "/app/app.jar"]
``` 

```bash
docker image build -t dicas:v4 .
``` 

Com a **Dica #4** A aplicação desta diretiva resulta numa redução drástica no tamanho final da imagem em disco.

![melhores-práticas-dica4](resources/02melhores-praticas-dica4.png)

#### Dica #5: Limpar a Cache do Gestor de Pacotes na Mesma Camada

Sistemas operativos como o Debian e o Ubuntu armazenam ficheiros temporários e índices de repositórios em /var/lib/apt/lists/ durante o apt-get update. Se não remover estes ficheiros na mesma instrução RUN em que foram criados, eles ficarão gravados permanentemente nessa camada imutável, e apagá-los num RUN posterior não libertará espaço no disco.

![melhores-práticas-5](resources/02melhores-praticas-5.png)

```bash
vim Dockerfile
```

```dockerfile
FROM        debian:9
RUN         apt-get update \
         && apt-get install -y --no-install-recommends \
            openjdk-8-jre \
         && rm -rf /var/lib/apt/lists/* \
         && rm -rf /var/cache/apt/*
COPY        app/target/app.jar /app/app.jar
COPY        app/samples /samples
ENTRYPOINT  ["java", "-jar", "/app/app.jar"]
``` 

```bash
docker image build -t dicas:v5 .
``` 

Agora com a **Dica #5** nossa imagem ficou relativamente menor.

![melhores-práticas-dica5](resources/02melhores-praticas-dica5.png)

#### Dica #6: Adotar Imagens Oficiais Preparadas
Sempre que exequível, evite configurar o sistema operativo do zero. O uso de imagens oficiais curadas pela comunidade e mantidas pelos fabricantes (como a imagem oficial do openjdk, node, python, etc.) garante a aplicação imediata das melhores práticas de segurança e configuração, além de permitir a partilha de camadas comuns entre múltiplos projetos no mesmo servidor.

![melhores-práticas-6](resources/02melhores-praticas-6.png)

```bash
vim Dockerfile
```

```dockerfile
FROM        openjdk
COPY        app/target/app.jar /app/app.jar
COPY        app/samples /samples
ENTRYPOINT  ["java", "-jar", "/app/app.jar"]
``` 

```bash
docker image build -t dicas:v6 .
``` 

#### Dica #7: Declarar Tags Específicas e Evitar a latest

A etiqueta latest é apenas um ponteiro dinâmico para a versão mais recente lançada pelo mantenedor. Confiar na latest em ambientes de produção é um risco crítico: se a imagem base for atualizada com alterações disruptivas (breaking changes), o seu próximo build automatizado irá quebrar a aplicação sem aviso prévio. Seja específico.

![melhores-práticas-7](resources/02melhores-praticas-7.png)

```bash
vim Dockerfile
```

```dockerfile
# Fixa a versão maior do ambiente para garantir consistência
FROM        openjdk:8
COPY        app/target/app.jar /app/app.jar
COPY        app/samples /samples
ENTRYPOINT  ["java", "-jar", "/app/app.jar"]
``` 

```bash
docker image build -t dicas:v7 .
``` 

#### Dica #8: Procure por flavors mínimos

Dica #8: Procurar por Variantes Minimalistas (slim e alpine)
Os repositórios oficiais oferecem habitualmente diferentes variantes (flavours) de imagem de acordo com a necessidade:

- slim: Uma imagem baseada em distribuições tradicionais (como Debian), mas despida de utilitários secundários e documentação, mantendo a biblioteca padrão GNU libc (glibc).
- alpine: Uma imagem baseada no Alpine Linux, um ecossistema ultra-minimalista focado em segurança que utiliza a biblioteca musl libc e ferramentas BusyBox. O seu tamanho base ronda escassos 5 MB.

Podemos auditar a diferença de tamanhos descarregando as variantes do OpenJDK:


```bash
docker image pull openjdk:8
docker image pull openjdk:8-jre
docker image pull openjdk:8-jre-slim
docker image pull openjdk:8-jre-alpine

# Filtra o resultado para análise
docker image ls | egrep "REPOSITORY|openjdk"
```
Output de comparação de tamanhos:

```bash
REPOSITORY          TAG                 SIZE
openjdk             8                   510MB
openjdk             8-jre               265MB
openjdk             8-jre-slim          184MB
openjdk             8-jre-alpine        84.9MB
``` 
Substituindo a imagem base no nosso ficheiro:

```dockerfile
FROM        openjdk:8-jre-alpine
COPY        app/target/app.jar /app/app.jar
COPY        app/samples /samples
ENTRYPOINT  ["java", "-jar", "/app/app.jar"]
```

```bash
docker image build -t dicas:v8 .
```

Agora temos uma diminuição enorme em nossa imagem pois estamos utilizando uma imagem base bem menor.

![melhores-práticas-dica8](resources/02melhores-praticas-dica8.png)

#### Dica #9: Compilação em Múltiplos Estágios (Multi-stage Build)
Introduzido na versão 17.05 do Docker, o Multi-stage build é um dos recursos mais potentes para otimização de infraestrutura. Ele permite a utilização de múltiplas diretivas FROM dentro do mesmo Dockerfile.

Com isto, podemos criar um primeiro estágio pesado (contendo compiladores, dependências de desenvolvimento e ferramentas de teste), gerar o binário final e, no segundo estágio, iniciar uma imagem minimalista (como o Alpine) e copiar apenas o binário resultante do estágio anterior. Todo o lixo de compilação é descartado automaticamente.

Vamos testar este cenário clonando uma aplicação escrita em Go:

```bash
git clone https://github.com/alexellis/href-counter.git ~/dockerfiles/multistage
cd ~/dockerfiles/multistage
rm -f Dockerfile*
vim Dockerfile
```

Se construirmos a imagem mantendo o compilador do Go lá dentro:

```dockerfile
FROM     golang:1.7.3
WORKDIR  go/src/github.com/alexellis/href-counter/
RUN      go get -d -v golang.org/x/net/html  
COPY     app.go .
RUN      CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .
CMD      ["./app"]
``` 

```bash
docker  image build -t multistage:v1 . 
``` 
Esta imagem resulta num tamanho massivo de aproximadamente 700 MB.

Utilizamos o argumento AS <nome> no primeiro FROM para nomear o estágio de compilação, e a flag --from=<nome> no COPY do segundo estágio para extrair estritamente o binário:


```bash
vim Dockerfile
```

```dockerfile
# Estágio 1: O Builder (Compilação)
FROM     golang:1.7.3 AS builder
WORKDIR  /go/src/github.com/alexellis/href-counter/
RUN      go get -d -v golang.org/x/net/html
COPY     app.go    .
RUN      CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

# Estágio 2: O Runner (Ambiente de Execução Mínimo)
FROM     alpine:latest
RUN      apk --no-cache add ca-certificates
WORKDIR  /root/
# Extração cirúrgica do binário compilado no estágio anterior
COPY     --from=builder /go/src/github.com/alexellis/href-counter/app .
CMD      ["./app"]
``` 

![melhores-práticas-9](resources/02melhores-praticas-9.png)


```bash
docker image build -t multistage:v2 .
``` 

Comparando os resultados obtidos no repositório:



```bash
docker image ls | egrep "REPOSITORY|multistage"
``` 

```bash
REPOSITORY        TAG               IMAGE ID        CREATED           SIZE
multistage        v1                dae3f0761024    28 minutes ago    700MB
multistage        v2                a1108a2b5102    2 seconds ago     11.7MB
``` 

Conseguimos uma redução impressionante de 700 MB para apenas 11.7 MB, mantendo a aplicação 100% funcional.

```bash
docker container run --rm -it -e url=https://youtube.com/caiodelgadonew multistage:v1
docker container run --rm -it -e url=https://youtube.com/caiodelgadonew multistage:v2
``` 

Adicionalmente, a flag --from também aceita como argumento o nome de uma imagem externa já existente no sistema. Isto permite extrair artefactos diretamente de outras imagens sem necessitar de criar estágios no ficheiro atual:


```bash
mkdir -p ~/dockerfiles/multistage2
cd ~/dockerfiles/multistage2
vim Dockerfile
```

```dockerfile
FROM     alpine:latest
WORKDIR  /root/
# Copia um ficheiro de amostra diretamente da imagem dicas:v7 criada anteriormente
COPY     --from=dicas:v7 /samples/1.txt .
CMD      ["cat", "1.txt"]
``` 


```bash
docker image build -t multistage:v3 .
# Testa a execução do contentor para validar o ficheiro extraído
docker container run --rm -it multistage:v3
``` 

Para expurgar o seu ambiente local de laboratório de todas as imagens pendentes, camadas intermédias e caches acumuladas durante estes testes de otimização, execute o comando de purga profunda:

`docker image prune -a`

Embora tenhamos visto que o uso do commit deve ser evitado em fluxos de produção automatizados, o exame de certificação DCA exige o conhecimento das suas flags de injeção de metadados. Elas permitem documentar a imagem gerada de forma semelhante ao que fazemos no Git ou num Dockerfile.

A sintaxe oficial orientada a objetos é:

```bash
docker container commit [OPÇÕES] CONTENTOR [REPOSITÓRIO[:TAG]]
```

**Opções Estruturais do Comando**

| **Opção**         | **Descrição Técnica**                                                                                                                                                     | **Exemplo Prático**                                                                         |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| `-m`, `--message` | Associa uma mensagem descritiva ao histórico da imagem, semelhante ao parâmetro `-m` do Git.                                                                              | `docker container commit -m "Instalado nginx e pacotes de rede" webserver meu-repo:v1`      |
| `-a`, `--author`  | Define o nome e o endereço de e-mail do autor responsável pela criação da imagem.                                                                                         | `docker container commit -a "Paulo Silva <paulo@empresa.com>" webserver meu-repo:v1`        |
| `-c`, `--change`  | Permite aplicar instruções válidas de um Dockerfile (`ENV`, `EXPOSE`, `CMD`, `ENTRYPOINT`, entre outras) diretamente na nova imagem durante o processo de criação.        | `docker container commit -c "ENV NODE_ENV=production" -c "EXPOSE 80" webserver meu-node:v1` |
| `--pause`         | Controla se os processos do contentor serão temporariamente suspensos durante a criação da imagem. O valor predefinido é `true`, garantindo maior consistência dos dados. | `docker container commit --pause=false webserver meu-repo:v1`                               |

### Esclarecimento de Conceitos: commit vs. save vs. push

É muito comum confundir o propósito destes três comandos na gestão de ciclo de vida das imagens. Memorize este resumo para o exame:

- docker container commit: Pega num contentor ativo/parado (camada Read-Write) e transforma-o numa nova imagem local (camada Read-Only). Não envia nada para a internet e não gera ficheiros externos.
- docker image save: Pega numa imagem local e exporta-a para um ficheiro físico comprimido (.tar) no disco rígido do host, ideal para transporte offline via pen USB ou rede interna.
- docker image push: Pega numa imagem local e faz o upload das suas camadas para um registo remoto na nuvem (como o Docker Hub ou AWS ECR), tornando-a acessível globalmente via internet.

## Resumo

O objetivo central deste capítulo foi transformar a escrita de Dockerfiles casuais num processo de engenharia de infraestrutura focado em segurança, portabilidade, performance (reutilização de cache) e minimização do tamanho das imagens.

Com este capítulo fechado, o manual cobre com distinção toda a mecânica profunda de armazenamento, otimização e distribuição de imagens Docker exigida pelo mercado.
