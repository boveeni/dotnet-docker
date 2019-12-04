FROM mcr.microsoft.com/dotnet/core/aspnet:3.0-stretch-slim AS base

RUN apt update && \
    apt install unzip && \
    curl -sSL https://aka.ms/getvsdbgsh | /bin/sh /dev/stdin -v latest -l /vsdbg

WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/core/sdk:3.0-stretch AS build
WORKDIR /src
COPY ["dotnet-docker.csproj", ""]
RUN dotnet restore "./dotnet-docker.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "dotnet-docker.csproj" -c Debug -o /app/build

FROM node:stretch-slim AS node
COPY ["./ClientApp/", "/ClientApp"]
WORKDIR /ClientApp
RUN npm install
RUN npm run build


FROM build AS publish
RUN dotnet publish "dotnet-docker.csproj" -c Debug -o /app/publish
COPY --from=node /ClientApp/build ./app/publish/ClientApp


FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "dotnet-docker.dll"]