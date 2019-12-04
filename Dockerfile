FROM mcr.microsoft.com/dotnet/core/aspnet:3.0-buster-slim AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/core/sdk:3.0-buster AS build
WORKDIR /src
COPY ["dotnet-docker.csproj", ""]
RUN dotnet restore "./dotnet-docker.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "dotnet-docker.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "dotnet-docker.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "dotnet-docker.dll"]