export default function Home() {
  return (
    <div className="font-sans min-h-screen flex items-center justify-center bg-gradient-to-r from-blue-500 to-purple-600">
      <main className="text-center">
        <h1 className="text-4xl md:text-6xl font-bold text-white mb-4 opacity-0 transform translate-y-4 animate-[fadeIn_1s_ease-out_forwards]">
          Hi, Welcome to the EC2 Server
        </h1>
        <p className="text-xl text-white/80 opacity-0 transform translate-y-4 animate-[fadeIn_1s_ease-out_0.3s_forwards]">
          Your application is now running on AWS EC2
        </p>
      </main>
    </div>
  );
}

